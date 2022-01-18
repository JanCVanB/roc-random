interface Random
    exposes [
        int,
        next,
        seed32,
        step,
        u32,
    ]
    imports []


#### Types

Generator seed value : seed -> Generation seed value
Generation seed value : { seed, value }

Seed32 : [ Seed32 U32 ]*


## ## Helpers for all generators

next : Generation seed *, Generator seed value -> Generation seed value
next = \x, g -> g x.seed

seed32 : U32 -> Seed32
seed32 = \state -> Seed32 state

step : seed, Generator seed value -> Generation seed value
step = \s, g -> g s


## ## Constructors for primitive generators

# TODO: This is waiting on `convertU32ToI32`.
# i32 : I32, I32 -> Generator Seed32 I32
# i32 = \x, y ->
#     between x y (\seed -> convertU32ToI32 (growSeed32 seed)) (\seed -> updateSeed32 seed)

# TODO: This is waiting on `convertU64ToI64` & `growseed64`.
# i64 : I64, I64 -> Generator Seed64 I64
# i64 = \x, y ->
#     between x y (\seed -> convertU64ToI64 (growSeed64 seed)) (\seed -> updateSeed64 seed)

# TODO: This is waiting on `convertU128ToI128` & `growseed128`.
# i128 : I128, I128 -> Generator Seed128 I128
# i128 = \x, y ->
#     between x y (\seed -> convertU128ToI128 (growSeed128 seed)) (\seed -> updateSeed128 seed)

int = u32

u32 : U32, U32 -> Generator Seed32 U32
u32 = \x, y ->
    between x y (\seed -> growSeed32 seed) (\seed -> updateSeed32 seed)

# TODO: This is waiting on `growSeed64`.
# u64 : U64, U64 -> Generator Seed64 U64
# u64 = \x, y ->
#     between x y (\seed -> growSeed64 seed) (\seed -> updateSeed64 seed)

# TODO: This is waiting on `growSeed64`.
# u128 : U128, U128 -> Generator Seed128 U128
# u128 = \x, y ->
#     between x y (\seed -> growSeed128 seed) (\seed -> updateSeed128 seed)


#### Generator helpers

between = \x, y, growSeed, updateSeed ->
    Pair minimum maximum = sort x y
    range = maximum - minimum + 1
    \seed ->
        value = minimum + modWithNonzero (growSeed seed) range
        { value, seed: updateSeed seed }

# TODO: This is waiting on `Num.toI8` (https://github.com/rtfeldman/roc/issues/664).
# convertU8ToI8 : U8 -> I8
# convertU8ToI8 = \x ->
#     minimum : I8
#     minimum = Num.minI8
#     maximum : I8
#     maximum = Num.maxI8
#     if x <= maximum then
#         Num.toI8 x + minimum
#     else
#         Num.toI8 (x + minimum)

# TODO: This is waiting on `Num.toI16` (https://github.com/rtfeldman/roc/issues/664).
# convertU16ToI16 : U16 -> I16
# convertU16ToI16 = \x ->
#     minimum : I16
#     minimum = Num.minI16
#     maximum : I16
#     maximum = Num.maxI16
#     if x <= maximum then
#         Num.toI16 x + minimum
#     else
#         Num.toI16 (x + minimum)

# TODO: This is waiting on `Num.toI32` (https://github.com/rtfeldman/roc/issues/664).
# convertU32ToI32 : U32 -> I32
# convertU32ToI32 = \x ->
#     minimum : I32
#     minimum = Num.minI32
#     maximum : I32
#     maximum = Num.maxI32
#     if x <= maximum then
#         Num.toI32 x + minimum
#     else
#         Num.toI32 (x + minimum)

# TODO: This is waiting on `Num.toI64` (https://github.com/rtfeldman/roc/issues/664).
# convertU64ToI64 : U64 -> I64
# convertU64ToI64 = \x ->
#     minimum : I64
#     minimum = Num.minI64
#     maximum : I64
#     maximum = Num.maxI64
#     if x <= maximum then
#         Num.toI64 x + minimum
#     else
#         Num.toI64 (x + minimum)

# TODO: This is waiting on `Num.toI128` (https://github.com/rtfeldman/roc/issues/664).
# convertU128ToI128 : U128 -> I128
# convertU128ToI128 = \x ->
#     minimum : I128
#     minimum = Num.minI128
#     maximum : I128
#     maximum = Num.maxI128
#     if x <= maximum then
#         Num.toI128 x + minimum
#     else
#         Num.toI128 (x + minimum)

# Warning: y must never equal 0. The `123` fallback is nonsense for typechecking only.
modWithNonzero = \x, y -> x % y |> Result.withDefault 123

sort = \x, y ->
    if x < y then
        Pair x y
    else
        Pair y x


#### PCG algorithms & wrappers
# 
# Based on this paper: https://www.pcg-random.org/pdf/hmc-cs-2014-0905.pdf
# Based on this C++ header: https://github.com/imneme/pcg-c/blob/master/include/pcg_variants.h
# Abbreviations:
#     M = Multiplication (see section 6.3.4 on page 45 in the paper)
#     PCG = Permuted Congruential Generator
#     RXS = Random XorShift (see section 5.5.1 on page 36 in the paper)
#     XS = XorShift (see section 5.5 on page 34 in the paper)

# See `pcg_output_rxs_m_xs_32_32` (on line 182?) in the C++ header.
growSeed32 = Seed32 -> U32
growSeed32 = \Seed32 state ->
    rxs : U32
    rxs = 28
    rxsi : U32
    rxsi = 4
    m : U32
    m = 277_803_737
    xs : U32
    xs = 22
    pcgRxsMXs state rxs rxsi m xs

# TODO: This is waiting on literals > maxI64 (https://github.com/rtfeldman/roc/issues/2332).
# # See `pcg_output_rxs_m_xs_64_64` (on line 188?) in the C++ header.
# growSeed64 = Seed64 -> U64
# growSeed64 = \Seed64 state ->
#     rxs : U64
#     rxs = 59
#     rxsi : U64
#     rxsi = 5
#     m : U64
#     m = 12_605_985_483_714_917_081
#     xs : U64
#     xs = 43
#     pcgRxsMXs state rxs rxsi m xs

# TODO: This is waiting on literals > maxI64 (https://github.com/rtfeldman/roc/issues/2332).
# # See `pcg_output_rxs_m_xs_128_128` (on line 196?) in the C++ header.
# growSeed128 = Seed128 -> U128
# growSeed128 = \Seed128 state ->
#     rxs : U128
#     rxs = 122
#     rxsi : U128
#     rxsi = 6
#     m : U128
#     m = (Num.shiftLeftBy 64 17_766_728_186_571_221_404) + 12_605_985_483_714_917_081
#     xs : U128
#     xs = 86
#     pcgRxsMXs state rxs rxsi m xs

# See section 6.3.4 on page 45 in the paper.
pcgRxsMXs : Int a, Int a, Int a, Int a, Int a -> Int a
pcgRxsMXs = \state, randomBitshift, randomBitshiftIncrement, multiplier, bitshift ->
    partial = Num.mulWrap multiplier (
        Num.bitwiseXor state (
            Num.shiftRightZfBy (
                Num.addWrap (Num.shiftRightZfBy randomBitshift state) randomBitshiftIncrement
            ) state
        ))
    Num.bitwiseXor partial (Num.shiftRightZfBy bitshift partial)

# See section 4.1 on page 20 in the paper.
pcgUpdateState : Int a, Int a, Int a -> Int a
pcgUpdateState = \state, multiplier, increment ->
    Num.addWrap (Num.mulWrap state multiplier) increment

# See `pcg_oneseq_32_step_r` (line 504?) in the above C++ header
updateSeed32 : Seed32 -> Seed32
updateSeed32 = \Seed32 state ->
    multiplier : U32
    multiplier = 747_796_405
    # TODO: Replace this with user-supplied?
    increment : U32
    increment = 2_891_336_453
    Seed32 (pcgUpdateState state multiplier increment)

# TODO: This is waiting on 64-bit generators.
# # See `pcg_oneseq_64_step_r` (line 552?) in the above C++ header.
# updateSeed64 : Seed64 -> Seed64
# updateSeed64 = \Seed64 state -> 
#     multiplier : U64
#     multiplier = 6_364_136_223_846_793_005
#     # TODO: Replace this with user-supplied?
#     increment : U64
#     increment = 1_442_695_040_888_963_407
#     Seed64 (pcgUpdateState state multiplier increment)

# TODO: This is waiting on 128-bit generators.
# # See `pcg_oneseq_128_step_r` (line 601?) in the above C++ header.
# updateSeed128 : Seed128 -> Seed128
# updateSeed128 = \Seed128 state ->
#     multiplier : U128
#     multiplier = (Num.shiftLeftBy 64 2_549_297_995_355_413_924) + 4_865_540_595_714_422_341
#     # TODO: Replace this with user-supplied?
#     increment : U128
#     increment = (Num.shiftLeftBy 64 6_364_136_223_846_793_005) + 1_442_695_040_888_963_407
#     Seed128 (pcgUpdateState state multiplier increment)
