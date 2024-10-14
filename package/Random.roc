## ## PCG algorithms, constants, and wrappers
##
## For more information about PCG see [www.pcg-random.org](https://www.pcg-random.org)
##
## > PCG is a family of simple fast space-efficient statistically good algorithms for random number generation.
##
module [
    Generation,
    Generator,
    State,
    seed,
    seedVariant,
    step,
    next,
    static,
    map,
    chain,
    u8,
    boundedU8,
    i8,
    boundedI8,
    u16,
    boundedU16,
    i16,
    boundedI16,
    u32,
    boundedU32,
    i32,
    boundedI32,
]

# This implementation is based on this paper [PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation](https://www.pcg-random.org/pdf/hmc-cs-2014-0905.pdf)
# and this C++ header: [pcg_variants.h](https://github.com/imneme/pcg-c/blob/master/include/pcg_variants.h).
#
# Original Roc implementation by [JanCVanB](https://github.com/JanCVanB), January 2022
#
# Abbreviations:
# - M = Multiplication (see section 6.3.4 on page 45 in the paper)
# - PCG = Permuted Congruential Generator
# - RXS = Random XorShift (see section 5.5.1 on page 36 in the paper)
# - XS = XorShift (see section 5.5 on page 34 in the paper)

## A generator that produces pseudorandom `value`s using the PCG algorithm.
##
## ```
## rgbGenerator : Generator { red: U8, green: U8, blue: U8 }
## rgbGenerator =
##     { Random.chain <-
##         red: Random.u8,
##         green: Random.u8,
##         blue: Random.u8,
##     }
## ```
Generator value : State -> Generation value

## A pseudorandom value, paired with its [Generator]'s output state.
##
## This is required to chain multiple calls together passing the updated state.
Generation value : { value : value, state : State }

## Internal state for Generators
State := { s : U32, c : AlgorithmConstants }

# only used internally
AlgorithmConstants : {
    permuteMultiplier : U32,
    permuteRandomXorShift : U32,
    permuteRandomXorShiftIncrement : U32,
    permuteXorShift : U32,
    updateIncrement : U32,
    updateMultiplier : U32,
}

## Construct an initial "seed" [State] for [Generator]s
seed : U32 -> State
seed = \s -> seedVariant s defaultU32UpdateIncrement

## Construct a specific "variant" of a "seed" for more advanced use.
##
## A "seed" is an initial [State] for [Generator]s.
##
## A "variant" is a [State] that specifies a `c.updateIncrement` constant,
## to produce a sequence of internal `value`s that shares no consecutive pairs
## with other variants of the same [State].
##
## Odd numbers are recommended for the update increment,
## to double the repetition period of sequences (by hitting odd values).
seedVariant : U32, U32 -> State
seedVariant = \s, uI ->
    c = {
        permuteMultiplier: defaultU32PermuteMultiplier,
        permuteRandomXorShift: defaultU32PermuteRandomXorShift,
        permuteRandomXorShiftIncrement: defaultU32PermuteRandomXorShiftIncrement,
        permuteXorShift: defaultU32PermuteXorShift,
        updateIncrement: uI,
        updateMultiplier: defaultU32UpdateMultiplier,
    }

    @State { s, c }

## Generate a [Generation] from a state
step : State, Generator value -> Generation value
step = \s, g -> g s

## Generate a new [Generation] from an old [Generation]'s state
next : Generation *, Generator value -> Generation value
next = \x, g -> g x.state

## Create a [Generator] that always returns the same thing.
static : value -> Generator value
static = \value ->
    \state -> { value, state }

## Map over the value of a [Generator].
map : Generator a, (a -> b) -> Generator b
map = \generator, mapper ->
    \state ->
        { value, state: state2 } = generator state

        { value: mapper value, state: state2 }

## Compose two [Generator]s into a single [Generator].
##
## This works well with record builders:
##
## ```
## dateGenerator =
##     { Random.chain <-
##         year: Random.int 1 2500,
##         month: Random.int 1 12,
##         day: Random.int 1 31,
##     }
## ```
chain : Generator a, Generator b, (a, b -> c) -> Generator c
chain = \firstGenerator, secondGenerator, combiner ->
    \state ->
        { value: first, state: state2 } = firstGenerator state
        { value: second, state: state3 } = secondGenerator state2

        { value: combiner first second, state: state3 }

expect
    alwaysFive = static 5

    List.range { start: At 0, end: Before 100 }
    |> List.all \seedNum ->
        value =
            seed seedNum
            |> step alwaysFive
            |> .value

        value == 5

expect
    doubledInt = boundedI32 -100 100 |> map (\i -> i * 2)

    List.range { start: At 0, end: Before 100 }
    |> List.all \seedNum ->
        nextSeed = seed seedNum
        randInt = step nextSeed (boundedI32 -100 100) |> .value
        doubledRandInt = step nextSeed doubledInt |> .value

        randInt * 2 == doubledRandInt

expect
    colorComponentGen = boundedI32 0 255
    rgbGenerator =
        { chain <-
            r: colorComponentGen,
            g: colorComponentGen,
            b: colorComponentGen,
        }

    nextSeed = seed 123
    randRgb = step nextSeed rgbGenerator |> .value

    randRgb == { r: 65, g: 156, b: 137 }

## Construct a [Generator] for 8-bit unsigned integers
u8 : Generator U8
u8 = betweenUnsigned Num.minU8 Num.maxU8 |> map Num.intCast

## Construct a [Generator] for 8-bit unsigned integers between two boundaries (inclusive)
boundedU8 : U8, U8 -> Generator U8
boundedU8 = \x, y -> betweenUnsigned x y |> map Num.intCast

## Construct a [Generator] for 8-bit signed integers
i8 : Generator I8
i8 =
    (minimum, maximum) = (Num.minI8, Num.maxI8)
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI8) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI8
        { value, state: update state }

## Construct a [Generator] for 8-bit signed integers between two boundaries (inclusive)
boundedI8 : I8, I8 -> Generator I8
boundedI8 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI8) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI8
        { value, state: update state }

## Construct a [Generator] for 16-bit unsigned integers
u16 : Generator U16
u16 = betweenUnsigned Num.minU16 Num.maxU16 |> map Num.intCast

## Construct a [Generator] for 16-bit unsigned integers between two boundaries (inclusive)
boundedU16 : U16, U16 -> Generator U16
boundedU16 = \x, y -> betweenUnsigned x y |> map Num.intCast

## Construct a [Generator] for 16-bit signed integers
i16 : Generator I16
i16 =
    (minimum, maximum) = (Num.minI16, Num.maxI16)
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI16) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI16
        { value, state: update state }

## Construct a [Generator] for 16-bit signed integers between two boundaries (inclusive)
boundedI16 : I16, I16 -> Generator I16
boundedI16 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI16) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI16
        { value, state: update state }

## Construct a [Generator] for 32-bit unsigned integers
u32 : Generator U32
u32 = betweenUnsigned Num.minU32 Num.maxU32

## Construct a [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
boundedU32 : U32, U32 -> Generator U32
boundedU32 = \x, y -> betweenUnsigned x y

## Construct a [Generator] for 32-bit signed integers
i32 : Generator I32
i32 =
    (minimum, maximum) = (Num.minI32, Num.maxI32)
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI32) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI32
        { value, state: update state }

## Construct a [Generator] for 32-bit signed integers between two boundaries (inclusive)
boundedI32 : I32, I32 -> Generator I32
boundedI32 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI32) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI32
        { value, state: update state }

# Helpers for the above constructors -------------------------------------------
betweenUnsigned : Int a, Int a -> Generator (Int a)
betweenUnsigned = \x, y ->
    (minimum, maximum) = sort x y
    range = maximum - minimum |> Num.addChecked 1

    \s ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        value =
            when range is
                Ok r -> minimum + (Num.intCast (permute s)) % r
                Err _ -> permute s |> Num.intCast
        state = update s

        { value, state }

mapToI32 : U32 -> I32
mapToI32 = \x ->
    middle = Num.toU32 Num.maxI32
    if x <= middle then
        Num.minI32 + Num.toI32 x
    else
        Num.toI32 (x - middle - 1)

sort = \x, y ->
    if x < y then
        (x, y)
    else
        (y, x)

# See `RXS M XS` constants (line 168?)
# and `_DEFAULT_` constants (line 276?)
# in the PCG C++ header (see link above).
defaultU32PermuteMultiplier = 277_803_737
defaultU32PermuteRandomXorShift = 28
defaultU32PermuteRandomXorShiftIncrement = 4
defaultU32PermuteXorShift = 22
defaultU32UpdateIncrement = 2_891_336_453
defaultU32UpdateMultiplier = 747_796_405

# See `pcg_output_rxs_m_xs_8_8` (on line 170?) in the PCG C++ header (see link above).
permute : State -> U32
permute = \@State { s, c } ->
    pcgRxsMXs s c.permuteRandomXorShift c.permuteRandomXorShiftIncrement c.permuteMultiplier c.permuteXorShift

# See section 6.3.4 on page 45 in the PCG paper (see link above).
pcgRxsMXs : U32, U32, U32, U32, U32 -> U32
pcgRxsMXs = \state, randomXorShift, randomXorShiftIncrement, multiplier, xorShift ->

    inner =
        randomXorShift
        |> Num.shiftRightZfBy (Num.intCast state)
        |> Num.addWrap randomXorShiftIncrement
        |> Num.shiftRightZfBy (Num.intCast state)

    partial =
        state
        |> Num.bitwiseXor inner
        |> Num.mulWrap multiplier

    Num.bitwiseXor partial (Num.shiftRightZfBy xorShift (Num.intCast partial))

# See section 4.1 on page 20 in the PCG paper (see link above).
pcgStep : U32, U32, U32 -> U32
pcgStep = \state, multiplier, increment ->
    state
    |> Num.mulWrap multiplier
    |> Num.addWrap increment

# See `pcg_oneseq_8_step_r` (line 409?) in the PCG C++ header (see link above).
update : State -> State
update = \@State { s, c } ->

    sNew : U32
    sNew = pcgStep s c.updateMultiplier c.updateIncrement

    @State { s: sNew, c }

# Test U8 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = u8
    testSeed = seed 123
    actual = testGenerator testSeed
    expected = 65u8
    actual.value == expected

# Test U16 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = boundedU16 0 250
    testSeed = seed 123
    actual = testGenerator testSeed
    expected = 182u16
    actual.value == expected

# Test U32 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = boundedU32 0 250
    testSeed = seed 123
    actual = testGenerator testSeed
    expected = 143u32
    actual.value == expected

# Test I8 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = boundedI8 0 9
    testSeed = seed 6
    actual = testGenerator testSeed
    expected = -8i8
    actual.value == expected

# Test I16 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = boundedI16 0 9
    testSeed = seed 6
    actual = testGenerator testSeed
    expected = -8i16
    actual.value == expected

# Test I32 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = boundedI32 10 9
    testSeed = seed 6
    actual = testGenerator testSeed
    expected = 9i32
    actual.value == expected
