## ## PCG algorithms, constants, and wrappers
##
## Based on this paper [PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation](https://www.pcg-random.org/pdf/hmc-cs-2014-0905.pdf)
## and this C++ header: [pcg_variants.h](https://github.com/imneme/pcg-c/blob/master/include/pcg_variants.h)
##
## ## Abbreviations:
## - M = Multiplication (see section 6.3.4 on page 45 in the paper)
## - PCG = Permuted Congruential Generator
## - RXS = Random XorShift (see section 5.5.1 on page 36 in the paper)
## - XS = XorShift (see section 5.5 on page 34 in the paper)
module [
    Generation,
    Generator,
    State,
    i8,
    i16,
    i32,
    int,
    chain,
    next,
    seed,
    seedVariant,
    seed8,
    seed8Variant,
    seed16,
    seed16Variant,
    seed32,
    seed32Variant,
    step,
    u8,
    u16,
    u32,
]

## A pseudorandom value generator
Generator uint value : State uint -> Generation uint value

## A pseudorandom value, paired with its [Generator]'s output state (for chaining)
Generation uint value : { value : value, state : State uint }

## Internal state for [Generator]s
State uint := { s : uint, c : AlgorithmConstants uint }

AlgorithmConstants uint : {
    permuteMultiplier : uint,
    permuteRandomXorShift : uint,
    permuteRandomXorShiftIncrement : uint,
    permuteXorShift : uint,
    updateIncrement : uint,
    updateMultiplier : uint,
}

## Construct a "seed"
##
## A "seed" is an initial [State] for [Generator]s.
##
## This is an alias for [seed32].
seed : U32 -> State U32
seed = seed32

## Construct a specific "variant" of a "seed"
##
## A "seed" is an initial [State] for [Generator]s.
##
## A "variant" is a [State] that specifies a `c.updateIncrement` constant,
## to produce a sequence of internal `value`s that shares no consecutive pairs
## with other variants of the same [State].
##
## Odd numbers are recommended for the update increment,
## to double the repetition period of sequences (by hitting odd values).
##
## This is an alias for [seed32Variant].
seedVariant : U32, U32 -> State U32
seedVariant = seed32Variant

## Construct an initial [State] from 8 bits of noise
seed8 : U8 -> State U8
seed8 = \s -> seed8Variant s defaultU8UpdateIncrement

## Construct an initial [State] from 8 bits of noise and a specific increment for updating
seed8Variant : U8, U8 -> State U8
seed8Variant = \s, uI ->
    c = {
        permuteMultiplier: defaultU8PermuteMultiplier,
        permuteRandomXorShift: defaultU8PermuteRandomXorShift,
        permuteRandomXorShiftIncrement: defaultU8PermuteRandomXorShiftIncrement,
        permuteXorShift: defaultU8PermuteXorShift,
        updateIncrement: uI,
        updateMultiplier: defaultU8UpdateMultiplier,
    }

    @State { s, c }

## Construct an initial [State] from 16 bits of noise
seed16 : U16 -> State U16
seed16 = \s -> seed16Variant s defaultU16UpdateIncrement

## Construct an initial [State] from 16 bits of noise and a specific increment for updating
seed16Variant : U16, U16 -> State U16
seed16Variant = \s, uI ->
    c = {
        permuteMultiplier: defaultU16PermuteMultiplier,
        permuteRandomXorShift: defaultU16PermuteRandomXorShift,
        permuteRandomXorShiftIncrement: defaultU16PermuteRandomXorShiftIncrement,
        permuteXorShift: defaultU16PermuteXorShift,
        updateIncrement: uI,
        updateMultiplier: defaultU16UpdateMultiplier,
    }

    @State { s, c }

## Construct an initial [State] from 32 bits of noise
seed32 : U32 -> State U32
seed32 = \s -> seed32Variant s defaultU32UpdateIncrement

## Construct an initial [State] from 32 bits of noise and a specific increment for updating
seed32Variant : U32, U32 -> State U32
seed32Variant = \s, uI ->
    c = {
        permuteMultiplier: defaultU32PermuteMultiplier,
        permuteRandomXorShift: defaultU32PermuteRandomXorShift,
        permuteRandomXorShiftIncrement: defaultU32PermuteRandomXorShiftIncrement,
        permuteXorShift: defaultU32PermuteXorShift,
        updateIncrement: uI,
        updateMultiplier: defaultU32UpdateMultiplier,
    }

    @State { s, c }

chain : Generator uint a, Generator uint b, (a, b -> c) -> Generator uint c
chain = \firstGenerator, secondGenerator, combiner ->
    \state ->
        { value: first, state: state2 } = firstGenerator state
        { value: second, state: state3 } = secondGenerator state2

        { value: combiner first second, state: state3 }

## Generate a new [Generation] from an old [Generation]'s state
next : Generation uint *, Generator uint value -> Generation uint value
next = \x, g -> g x.state

## Generate a [Generation] from a state
step : State uint, Generator uint value -> Generation uint value
step = \s, g -> g s

## Construct a [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
##
## This is an alias for [i32].
int : I32, I32 -> Generator U32 I32
int = i32

## Construct a [Generator] for 8-bit signed integers between two boundaries (inclusive)
i8 : I8, I8 -> Generator U8 I8
i8 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI8 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI8) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI8
        { value, state: update state }

## Construct a [Generator] for 16-bit signed integers between two boundaries (inclusive)
i16 : I16, I16 -> Generator U16 I16
i16 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI16 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI16) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI16
        { value, state: update state }

## Construct a [Generator] for 32-bit signed integers between two boundaries (inclusive)
i32 : I32, I32 -> Generator U32 I32
i32 = \x, y ->
    (minimum, maximum) = sort x y
    # TODO: Remove these `I64` dependencies.
    range = (Num.toI64 maximum) - (Num.toI64 minimum) + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI32) |> Num.rem range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI32
        { value, state: update state }

## Construct a [Generator] for 8-bit unsigned integers between two boundaries (inclusive)
u8 : U8, U8 -> Generator U8 U8
u8 = \x, y -> betweenUnsigned x y

## Construct a [Generator] for 16-bit unsigned integers between two boundaries (inclusive)
u16 : U16, U16 -> Generator U16 U16
u16 = \x, y -> betweenUnsigned x y

## Construct a [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
u32 : U32, U32 -> Generator U32 U32
u32 = \x, y -> betweenUnsigned x y

# Helpers for the above constructors -------------------------------------------

betweenUnsigned = \x, y ->
    (minimum, maximum) = sort x y
    range = maximum - minimum |> Num.addChecked 1

    \s ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        value =
            when range is
                Ok r -> minimum + (permute s) % r
                Err _ -> permute s
        state = update s

        { value, state }

mapToI8 : U8 -> I8
mapToI8 = \x ->
    middle = Num.toU8 Num.maxI8
    if x <= middle then
        Num.minI8 + Num.toI8 x
    else
        Num.toI8 (x - middle - 1)

mapToI16 : U16 -> I16
mapToI16 = \x ->
    middle = Num.toU16 Num.maxI16
    if x <= middle then
        Num.minI16 + Num.toI16 x
    else
        Num.toI16 (x - middle - 1)

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
defaultU8PermuteMultiplier = 217
defaultU8PermuteRandomXorShift = 6
defaultU8PermuteRandomXorShiftIncrement = 2
defaultU8PermuteXorShift = 6
defaultU8UpdateIncrement = 77
defaultU8UpdateMultiplier = 141
defaultU16PermuteMultiplier = 62169
defaultU16PermuteRandomXorShift = 13
defaultU16PermuteRandomXorShiftIncrement = 3
defaultU16PermuteXorShift = 11
defaultU16UpdateIncrement = 47989
defaultU16UpdateMultiplier = 12829
defaultU32PermuteMultiplier = 277_803_737
defaultU32PermuteRandomXorShift = 28
defaultU32PermuteRandomXorShiftIncrement = 4
defaultU32PermuteXorShift = 22
defaultU32UpdateIncrement = 2_891_336_453
defaultU32UpdateMultiplier = 747_796_405
# TODO: Debug these untested 64-bit functions
# defaultU64PermuteMultiplier = 12_605_985_483_714_917_081
# defaultU64PermuteRandomXorShift = 59
# defaultU64PermuteRandomXorShiftIncrement = 5
# defaultU64PermuteXorShift = 43
# defaultU64UpdateIncrement = 1_442_695_040_888_963_407
# defaultU64UpdateMultiplier = 6_364_136_223_846_793_005
# TODO: Debug these untested 128-bit functions
# defaultU128PermuteMultiplier = (Num.shiftLeftBy 64 17_766_728_186_571_221_404) + 12_605_985_483_714_917_081
# defaultU128PermuteRandomXorShift = 122
# defaultU128PermuteRandomXorShiftIncrement = 6
# defaultU128PermuteXorShift = 86
# defaultU128UpdateIncrement = (Num.shiftLeftBy 64 6_364_136_223_846_793_005) + 1_442_695_040_888_963_407
# defaultU128UpdateMultiplier = (Num.shiftLeftBy 64 2_549_297_995_355_413_924) + 4_865_540_595_714_422_341

# See `pcg_output_rxs_m_xs_8_8` (on line 170?) in the PCG C++ header (see link above).
permute : State (Int uint) -> Int uint
permute = \@State { s, c } ->
    pcgRxsMXs s c.permuteRandomXorShift c.permuteRandomXorShiftIncrement c.permuteMultiplier c.permuteXorShift

# See section 6.3.4 on page 45 in the PCG paper (see link above).
pcgRxsMXs : Int uint, Int uint, Int uint, Int uint, Int uint -> Int uint
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
pcgStep : Int uint, Int uint, Int uint -> Int uint
pcgStep = \state, multiplier, increment ->
    state
    |> Num.mulWrap multiplier
    |> Num.addWrap increment

# See `pcg_oneseq_8_step_r` (line 409?) in the PCG C++ header (see link above).
update : State (Int uint) -> State (Int uint)
update = \@State { s, c } ->

    sNew : Int uint
    sNew = pcgStep s c.updateMultiplier c.updateIncrement

    @State { s: sNew, c }

# Test U8 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = u8 0 250
    testSeed = seed8 123
    actual = testGenerator testSeed
    expected = 67u8
    actual.value == expected

# Test U16 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = u16 0 250
    testSeed = seed16 123
    actual = testGenerator testSeed
    expected = 183u16
    actual.value == expected

# Test U32 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = u32 0 250
    testSeed = seed32 123
    actual = testGenerator testSeed
    expected = 143u32
    actual.value == expected

# Test I8 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = i8 0 9
    testSeed = seed8 6
    actual = testGenerator testSeed
    expected = 2i8
    actual.value == expected

# Test I16 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = i16 0 9
    testSeed = seed16 6
    actual = testGenerator testSeed
    expected = 4i16
    actual.value == expected

# Test I32 generation
# TODO confirm this is the right value for this seed
expect
    testGenerator = i32 0 9
    testSeed = seed32 6
    actual = testGenerator testSeed
    expected = 2i32
    actual.value == expected
