interface Random
    exposes [
        i32,
        i64,
        i128,
        int,
        next,
        seed,
        seed32,
        seed64,
        seed128,
        step,
        u32,
        u64,
        u128,
    ]
    imports []


## Types

Generator seed value : seed -> Generation seed value
Generation seed value : { seed, value }

Seed32 : [ @Seed32 U32 ]
Seed64 : [ @Seed64 U64 ]
Seed128 : [ @Seed128 U128 ]
AnySeed : [ @Seed32 U32, @Seed64 U64, @Seed128 U128 ]


## Public helpers

next : Generation *, Generator seed value -> Generation seed value
next = \x, g -> g x.seed

seed = seed64
seed32 : U32 -> Seed32
seed32 = \state -> @Seed32 state
seed64 : U64 -> Seed64
seed64 = \state -> @Seed64 state
seed128 : U128 -> Seed128
seed128 = \state -> @Seed128 state

step : AnySeed, Generator seed value -> Generation seed value
step = \s, g -> g s


## Public constructors for common generators

# TODO: Support generating `I32` from `Seed64`, etc.
i32 : I32, I32 -> Generator Seed32 I32
i32 = \x, y ->
    between x y (\seed -> convertU32ToI32 (growSeed32 seed)) (\seed -> updateSeed32 seed)

i64 : I64, I64 -> Generator Seed64 I64
i64 = \x, y ->
    between x y (\seed -> convertU32ToI32 (growSeed64 seed)) (\seed -> updateSeed64 seed)

i128 : I128, I128 -> Generator Seed128 I128
i128 = \x, y ->
    between x y (\seed -> convertU32ToI32 (growSeed128 seed)) (\seed -> updateSeed128 seed)

int = i64

u32 : U32, U32 -> Generator Seed32 U32
u32 = \x, y ->
    between x y (\seed -> growSeed32 seed) (\seed -> updateSeed32 seed)

u64 : U64, U64 -> Generator Seed64 U64
u64 = \x, y ->
    between x y (\seed -> growSeed64 seed) (\seed -> updateSeed64 seed)

u128 : U128, U128 -> Generator Seed128 U128
u128 = \x, y ->
    between x y (\seed -> growSeed128 seed) (\seed -> updateSeed128 seed)


## Private helpers for common generators

between = \x, y, growSeed, updateSeed ->
    Pair minimum maximum = sort x y
    range = maximum - minimum + 1
    \seed ->
        value = modWithNonzero (minimum + growSeed seed) range
        { value, seed: updateSeed seed }

convertU32ToI32 = \x ->
    minimum : I32
    minimum = -2_147_483_648
    maximum : I32
    maximum = 2_147_483_647
    if x <= maximum then
        Num.toI32 x + minimum
    else
        Num.toI32 (x + minimum)

convertU64ToI64 = \x ->
    minimum : I64
    minimum = -9_223_372_036_854_775_808
    maximum : I64
    maximum = 9_223_372_036_854_775_807
    if x <= maximum then
        Num.toI64 x + minimum
    else
        Num.toI64 (x + minimum)

convertU128ToI128 = \x ->
    minimum : I128
    minimum = -170_141_183_460_469_231_731_687_303_715_884_105_728
    maximum : I128
    maximum = 170_141_183_460_469_231_731_687_303_715_884_105_727
    if x <= maximum then
        Num.toI128 x + minimum
    else
        Num.toI128 (x + minimum)

# Warning: y must never equal 0. The `123` fallback is nonsense for typechecking only.
modWithNonzero = \x, y -> x % y |> Result.withDefault 123

sort = \x, y ->
    if x < y then
        Pair x y
    else
        Pair y x


## PCG algorithms & wrappers
# 
# Based on this paper: https://www.pcg-random.org/pdf/hmc-cs-2014-0905.pdf
# Based on this C++ header: https://github.com/imneme/pcg-c/blob/master/include/pcg_variants.h
# Abbreviations:
#     M = Multiplication (see section 6.3.4 on page 45 in the paper)
#     PCG = Permuted Congruential Generator
#     RXS = Random XorShift (see section 5.5.1 on page 36 in the paper)
#     XS = XorShift (see section 5.5 on page 34 in the paper)

# See `pcg_output_rxs_m_xs_32_32` (on line 182?) in the C++ header.
growSeed32 = \@Seed32 state ->
    rxsa = 28
    rxsb = 4
    m = 277_803_737
    xs = 22
    pcgRxsMXs state rxsa rxsb m xs

# See `pcg_output_rxs_m_xs_64_64` (on line 188?) in the C++ header.
growSeed64 = \@Seed64 seed ->
    rxsa = 59
    rxsb = 5
    m = 12_605_985_483_714_917_081
    xs = 43
    pcgRxsMXs state rxsa rxsb m xs

# See `pcg_output_rxs_m_xs_128_128` (on line 196?) in the C++ header.
growSeed128 = \@Seed128 state ->
    rxsa = 122
    rxsb = 6
    m = (Num.shiftLeftBy 64 17_766_728_186_571_221_404) + 12_605_985_483_714_917_081
    xs = 86
    pcgRxsMXs state rxsa rxsb m xs

# See section 6.3.4 on page 45 in the paper.
pcgRxsMXs = \state, rxsa, rxsb, m, xs ->
    partial = (Num.bitwiseXor state (Num.shiftRightZfBy ((Num.shiftRightZfBy rxsa state) + rxsb) state)) * m
    output = Num.bitwiseXor partial (Num.shiftRightZfBy xs partial)
    output

# See section 4.1 on page 20 in the paper.
pcgUpdateState = \state, multiplier, increment -> state * multiplier + increment

# See `pcg_oneseq_32_step_r` (line 504?) in the above C++ header
updateSeed32 = \@Seed32 state ->
    multiplier = 747_796_405
    # TODO: Replace this with user-supplied?
    increment = 2_891_336_453
    @Seed32 (pcgUpdateState state multiplier increment)

# See `pcg_oneseq_64_step_r` (line 552?) in the above C++ header.
updateSeed64 = \@Seed64 state -> 
    multiplier = 6_364_136_223_846_793_005 
    increment = 1_442_695_040_888_963_407
    @Seed64 (pcgUpdateState state multiplier increment)

# See `pcg_oneseq_128_step_r` (line 601?) in the above C++ header.
updateSeed128 = \@Seed128 state ->
    multiplier = (Num.shiftLeftBy 64 2_549_297_995_355_413_924) + 4_865_540_595_714_422_341
    increment = (Num.shiftLeftBy 64 6_364_136_223_846_793_005) + 1_442_695_040_888_963_407
    @Seed128 (pcgUpdateState state multiplier increment)
