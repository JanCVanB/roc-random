interface RandomB
    exposes [
        Generation,
        Generator,
        State,
        i8,
        i16,
        i32,
        int,
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
    imports []


## # Types

## A psuedorandom value generator
Generator value state : state -> Generation value state

## A psuedorandom value, paired with its [Generator]'s output state (for chaining)
Generation value state : { value : value, state : state }

## Internal state for [Generator]s
State seed := { value : seed, constants : AlgorithmConstants seed }
AlgorithmConstants seed : {
    permuteMultiplier : seed,
    permuteRandomXorShift : seed,
    permuteRandomXorShiftIncrement : seed,
    permuteXorShift : seed,
    updateIncrement : seed,
    updateMultiplier : seed }


## # [State] constructors

Seeder seedType : seedType -> State seedType
VariantSeeder seedType : seedType, seedType -> State seedType

## Initialize a [State] for [Generator]s.
##
## This is an alias for [seed32].
seed : Seeder U32
seed = seed32

## Initialize a specific variant of a [State] for [Generator]s.
##
## For each seed value with N bits of noise, there are N "variants" of an initial [State]
## for each possible value of `updateIncrement` in the [AlgorithmConstants].
## No two variants of the same [State] will share any two consecutive internal/external values.
## Therefore, variants are useful for generating multiple distinct sequences from one initial sample of noise.
##
## Odd numbers are recommended for the update increment,
## to double the repetition period of sequences (by hitting both even & odd values).
##
## This is an alias for [seed32Variant].
seedVariant : VariantSeeder U32
seedVariant = seed32Variant

## Construct an initial [State] from 8 bits of noise
seed8 : Seeder U8
seed8 = \seedValue -> seed8Variant seedValue defaultU8UpdateIncrement

## Construct an initial [State] from 8 bits of noise and a specific increment for updating
seed8Variant : VariantSeeder U8
seed8Variant = \seedValue, updateIncrement ->
    @State {
        value: seedValue,
        constants: {
            permuteMultiplier: defaultU8PermuteMultiplier,
            permuteRandomXorShift: defaultU8PermuteRandomXorShift,
            permuteRandomXorShiftIncrement: defaultU8PermuteRandomXorShiftIncrement,
            permuteXorShift: defaultU8PermuteXorShift,
            updateIncrement,
            updateMultiplier: defaultU8UpdateMultiplier } }

## Construct an initial [State] from 16 bits of noise
seed16 : Seeder U16
seed16 = \seedValue -> seed16Variant seedValue defaultU16UpdateIncrement

## Construct an initial [State] from 16 bits of noise and a specific increment for updating
seed16Variant : VariantSeeder U16
seed16Variant = \seedValue, updateIncrement ->
    @State {
        value: seedValue,
        constants: {
            permuteMultiplier: defaultU16PermuteMultiplier,
            permuteRandomXorShift: defaultU16PermuteRandomXorShift,
            permuteRandomXorShiftIncrement: defaultU16PermuteRandomXorShiftIncrement,
            permuteXorShift: defaultU16PermuteXorShift,
            updateIncrement,
            updateMultiplier: defaultU16UpdateMultiplier } }

## Construct an initial [State] from 32 bits of noise
seed32 : Seeder U32
seed32 = \seedValue -> seed32Variant seedValue defaultU32UpdateIncrement

## Construct an initial [State] from 32 bits of noise and a specific increment for updating
seed32Variant : VariantSeeder U32
seed32Variant = \seedValue, updateIncrement ->
    @State {
        value: seedValue,
        constants: {
            permuteMultiplier: defaultU32PermuteMultiplier,
            permuteRandomXorShift: defaultU32PermuteRandomXorShift,
            permuteRandomXorShiftIncrement: defaultU32PermuteRandomXorShiftIncrement,
            permuteXorShift: defaultU32PermuteXorShift,
            updateIncrement,
            updateMultiplier: defaultU32UpdateMultiplier } }


## # [Generator] helpers

## Generate a new [Generation] from an old [Generation]'s state
next : Generation * state, Generator value state -> Generation value state
next = \generation, generator -> generator generation.state

## Generate a [Generation] from a state
step : state, Generator value state -> Generation value state
step = \state, generator -> generator state


## # Primitive [Generator] constructors

## This is an alias for [i32].
int = i32

## Construct a [Generator] for 8-bit signed integers between two boundaries (inclusive)
i8 : I8, I8, (I8 -> Generator a (State U8)) -> Generator a (State U8)
i8 = \x, y, yield ->
    Pair minimum maximum = sort x y
    # TODO: Remove these `I64` dependencies.
    range = maximum - minimum + 1 |> Num.toI64
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI8 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI8) |> modWithNonzero range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI8
        (yield value) (update state)

## Construct a [Generator] for 16-bit signed integers between two boundaries (inclusive)
i16 : I16, I16, (I16 -> Generator a (State U16)) -> Generator a (State U16)
i16 = \x, y, yield ->
    Pair minimum maximum = sort x y
    # TODO: Remove these `I64` dependencies.
    range = maximum - minimum + 1 |> Num.toI64
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI16 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI16) |> modWithNonzero range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI16
        (yield value) (update state)

## Construct a [Generator] for 32-bit signed integers between two boundaries (inclusive)
i32 : I32, I32, (I32 -> Generator a (State U32)) -> Generator a (State U32)
i32 = \x, y, yield ->
    Pair minimum maximum = sort x y
    # TODO: Remove these `I64` dependencies.
    range = maximum - minimum + 1 |> Num.toI64
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        offset = permute state |> mapToI32 |> Num.toI64 |> Num.sub (Num.toI64 Num.minI32) |> modWithNonzero range
        value = minimum |> Num.toI64 |> Num.add offset |> Num.toI32
        (yield value) (update state)

## Construct a [Generator] for 8-bit unsigned integers between two boundaries (inclusive)
u8 : U8, U8 -> Generator U8 (State U8)
u8 = \x, y -> betweenUnsigned x y

## Construct a [Generator] for 16-bit unsigned integers between two boundaries (inclusive)
u16 : U16, U16 -> Generator U16 (State U16)
u16 = \x, y -> betweenUnsigned x y

## Construct a [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
u32 : U32, U32 -> Generator U32 (State U32)
u32 = \x, y -> betweenUnsigned x y


#### Helpers for the above constructors

betweenUnsigned = \x, y ->
    Pair minimum maximum = sort x y
    range = maximum - minimum + 1
    \state ->
        # TODO: Analyze this. The mod-ing might be biased towards a smaller offset!
        value = minimum + modWithNonzero (permute state) range
        { value, state: update state }

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

# Warning: y must never equal 0. The `123` fallback is nonsense for typechecking only.
modWithNonzero = \x, y -> x % y

sort = \x, y ->
    if x < y then
        Pair x y
    else
        Pair y x


#### PCG algorithms, constants, and wrappers
#
# Based on this paper: https://www.pcg-random.org/pdf/hmc-cs-2014-0905.pdf
# Based on this C++ header: https://github.com/imneme/pcg-c/blob/master/include/pcg_variants.h
# Abbreviations:
#     M = Multiplication (see section 6.3.4 on page 45 in the paper)
#     PCG = Permuted Congruential Generator
#     RXS = Random XorShift (see section 5.5.1 on page 36 in the paper)
#     XS = XorShift (see section 5.5 on page 34 in the paper)

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
# TODO: These are waiting on 64-bit generators.
#       and literals > Num.maxI64 (https://github.com/rtfeldman/roc/issues/2332).
# defaultU64PermuteMultiplier = 12_605_985_483_714_917_081
# defaultU64PermuteRandomXorShift = 59
# defaultU64PermuteRandomXorShiftIncrement = 5
# defaultU64PermuteXorShift = 43
# defaultU64UpdateIncrement = 1_442_695_040_888_963_407
# defaultU64UpdateMultiplier = 6_364_136_223_846_793_005
# TODO: These are waiting on 128-bit generators.
#       and literals > Num.maxI64 (https://github.com/rtfeldman/roc/issues/2332).
# defaultU128PermuteMultiplier = (Num.shiftLeftBy 64 17_766_728_186_571_221_404) + 12_605_985_483_714_917_081
# defaultU128PermuteRandomXorShift = 122
# defaultU128PermuteRandomXorShiftIncrement = 6
# defaultU128PermuteXorShift = 86
# defaultU128UpdateIncrement = (Num.shiftLeftBy 64 6_364_136_223_846_793_005) + 1_442_695_040_888_963_407
# defaultU128UpdateMultiplier = (Num.shiftLeftBy 64 2_549_297_995_355_413_924) + 4_865_540_595_714_422_341

# See section 6.3.4 on page 45 in the PCG paper (see link above).
pcgRxsMXs = \stateValue, randomXorShift, randomXorShiftIncrement, multiplier, xorShift ->
    partial = Num.mulWrap multiplier (
        Num.bitwiseXor stateValue (
            Num.shiftRightZfBy (
                Num.addWrap (Num.shiftRightZfBy randomXorShift stateValue) randomXorShiftIncrement
            ) stateValue
        ))
    Num.bitwiseXor partial (Num.shiftRightZfBy xorShift partial)

# See section 4.1 on page 20 in the PCG paper (see link above).
pcgStep = \stateValue, multiplier, increment ->
    Num.addWrap (Num.mulWrap stateValue multiplier) increment

# See `pcg_output_rxs_m_xs_8_8` (on line 170?) in the PCG C++ header (see link above).
permute = \@State { value, constants } ->
    pcgRxsMXs value constants.permuteRandomXorShift constants.permuteRandomXorShiftIncrement constants.permuteMultiplier constants.permuteXorShift

# See `pcg_oneseq_8_step_r` (line 409?) in the PCG C++ header (see link above).
update = \@State { value, constants } ->
    @State { value: pcgStep value constants.updateMultiplier constants.updateIncrement, constants }
