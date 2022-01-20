interface Random
    exposes [
        Generator,
        Generation,
        Seed8,
        Seed16,
        Seed32,
        i8,
        i16,
        i32,
        int,
        next,
        seed,
        seed8,
        seed16,
        seed32,
        step,
        u8,
        u16,
        u32,
    ]
    imports []


## # Types

## A psuedorandom value generator
Generator seed value : seed -> Generation seed value

## A psuedorandom value, paired with an updated seed for future use
Generation seed value : { seed, value }

## An 8-bit seed
Seed8 : [ Seed8 U8 ]*

## A 16-bit seed
Seed16 : [ Seed16 U16 ]*

## A 32-bit seed
Seed32 : [ Seed32 U32 ]*


## # Constructors for seeds

## Constructs a 32-bit seed from an 32-bit integer
##
## This is an alias for [seed32].
seed : U32 -> Seed32
seed = seed32

## Constructs an 8-bit seed from an 8-bit integer
seed8 : U8 -> Seed8
seed8 = \state -> Seed8 state

## Constructs a 16-bit seed from a 16-bit integer
seed16 : U16 -> Seed16
seed16 = \state -> Seed16 state

## Constructs a 32-bit seed from a 32-bit integer
seed32 : U32 -> Seed32
seed32 = \state -> Seed32 state


## # Helpers for all generators

## Generates a new value from an old one (and update the seed)
next : Generation seed *, Generator seed value -> Generation seed value
next = \x, g -> g x.seed

## Generates a value from a seed (and update the seed)
step : seed, Generator seed value -> Generation seed value
step = \s, g -> g s


## # Constructors for some primitive generators

## A [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
##
## This is an alias for [i32].
int : I32, I32 -> Generator Seed32 I32
int = i32

## A [Generator] for 8-bit signed integers between two boundaries (inclusive)
i8 : I8, I8 -> Generator Seed8 I8
i8 = \x, y ->
    between x y (\s -> mapToI8 (growSeed8 s)) (\s -> updateSeed8 s)

## A [Generator] for 16-bit signed integers between two boundaries (inclusive)
i16 : I16, I16 -> Generator Seed16 I16
i16 = \x, y ->
    between x y (\s -> mapToI16 (growSeed16 s)) (\s -> updateSeed16 s)

## A [Generator] for 32-bit signed integers between two boundaries (inclusive)
i32 : I32, I32 -> Generator Seed32 I32
i32 = \x, y ->
    between x y (\s -> mapToI32 (growSeed32 s)) (\s -> updateSeed32 s)

# TODO: This is waiting on [growseed64].
# ## A [Generator] for 64-bit signed integers between two boundaries (inclusive)
# i64 : I64, I64 -> Generator Seed64 I64
# i64 = \x, y ->
#     between x y (\s -> mapToI64 (growSeed64 s)) (\s -> updateSeed64 s)

# TODO: This is waiting on [mapToI128] & [growseed128].
# ## A [Generator] for 128-bit signed integers between two boundaries (inclusive)
# i128 : I128, I128 -> Generator Seed128 I128
# i128 = \x, y ->
#     between x y (\s -> mapToI128 (growSeed128 s)) (\s -> updateSeed128 s)

## A [Generator] for 8-bit unsigned integers between two boundaries (inclusive)
u8 : U8, U8 -> Generator Seed8 U8
u8 = \x, y ->
    between x y (\s -> growSeed8 s) (\s -> updateSeed8 s)

## A [Generator] for 16-bit unsigned integers between two boundaries (inclusive)
u16 : U16, U16 -> Generator Seed16 U16
u16 = \x, y ->
    between x y (\s -> growSeed16 s) (\s -> updateSeed16 s)

## A [Generator] for 32-bit unsigned integers between two boundaries (inclusive)
u32 : U32, U32 -> Generator Seed32 U32
u32 = \x, y ->
    between x y (\s -> growSeed32 s) (\s -> updateSeed32 s)

# TODO: This is waiting on [growSeed64].
# ## A [Generator] for 64-bit unsigned integers between two boundaries (inclusive)
# u64 : U64, U64 -> Generator Seed64 U64
# u64 = \x, y ->
#     between x y (\s -> growSeed64 s) (\s -> updateSeed64 s)

# TODO: This is waiting on [growSeed64].
# ## A [Generator] for 128-bit unsigned integers between two boundaries (inclusive)
# u128 : U128, U128 -> Generator Seed128 U128
# u128 = \x, y ->
#     between x y (\s -> growSeed128 s) (\s -> updateSeed128 s)


#### Helpers for the above constructors

between = \x, y, growSeed, updateSeed ->
    Pair minimum maximum = sort x y
    range = maximum - minimum + 1
    \s ->
        value = minimum + modWithNonzero (growSeed s) range
        { value, seed: updateSeed s }

mapToI8 : U8 -> I8
mapToI8 = \x ->
    # TODO: Replace these with `Num.toI8`/`Num.toU8` when they're implemented
    #       (see https://github.com/rtfeldman/roc/issues/664).
    minI8 : I8
    minI8 = -128
    maxI8 : I8
    maxI8 = 127
    toI8 : U8 -> I8
    toI8 = \y -> y |> Num.toStr |> Str.toI8 |> Result.withDefault 0
    toU8 : I8 -> U8
    toU8 = \y -> y |> Num.toStr |> Str.toU8 |> Result.withDefault 0
    middle = toU8 maxI8
    if x <= middle then
        minI8 + toI8 x
    else
        toI8 (x - middle)

mapToI16 : U16 -> I16
mapToI16 = \x ->
    # TODO: Replace these with builtins when they're implemented
    #       (see https://github.com/rtfeldman/roc/issues/664).
    minI16 : I16
    minI16 = -32_768
    maxI16 : I16
    maxI16 = 32_767
    toI16 = \y -> y |> Num.toStr |> Str.toI16 |> Result.withDefault 0
    toU16 = \y -> y |> Num.toStr |> Str.toU16 |> Result.withDefault 0
    middle = toU16 maxI16
    if x <= middle then
        minI16 + toI16 x
    else
        toI16 (x - middle)

mapToI32 : U32 -> I32
mapToI32 = \x ->
    # TODO: Replace these with builtins when they're implemented
    #       (see https://github.com/rtfeldman/roc/issues/664).
    toI32 = \y -> y |> Num.toStr |> Str.toI32 |> Result.withDefault 0
    toU32 = \y -> y |> Num.toStr |> Str.toU32 |> Result.withDefault 0
    middle = toU32 Num.maxI32
    if x <= middle then
        Num.minI32 + toI32 x
    else
        toI32 (x - middle)

# TODO: This is waiting on the [i64] [Generator].
# mapToI64 : U64 -> I64
# mapToI64 = \x ->
#     # TODO: Replace these with `Num.toI64`/`Num.toU64` when they're implemented
#     #       (see https://github.com/rtfeldman/roc/issues/664).
#     toI64 = \y -> y |> Num.toStr |> Str.toI64 |> Result.withDefault 0
#     toU64 = \y -> y |> Num.toStr |> Str.toU64 |> Result.withDefault 0
#     middle = toU64 Num.maxI64
#     if x <= middle then
#         Num.minI64 + toI64 x
#     else
#         toI64 (x - middle)

# TODO: This is waiting on `Num.toI128` (https://github.com/rtfeldman/roc/issues/664)
#       to be implemented or for `Str.toI128` & `Str.toU128` to work.
# mapToI128 : U128 -> I128
# mapToI128 = \x ->
#     middle = Num.toU128 Num.maxI128
#     if x <= middle then
#         Num.minI128 + Num.toI128 x
#     else
#         Num.toI128 (x - middle)

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

# See `pcg_output_rxs_m_xs_8_8` (on line 170?) in the C++ header.
growSeed8 : Seed8 -> U8
growSeed8 = \Seed8 state ->
    rxs : U8
    rxs = 6
    rxsi : U8
    rxsi = 2
    m : U8
    m = 217
    xs : U8
    xs = 6
    pcgRxsMXs state rxs rxsi m xs

# See `pcg_output_rxs_m_xs_16_16` (on line 182?) in the C++ header.
growSeed16 : Seed16 -> U16
growSeed16 = \Seed16 state ->
    rxs : U16
    rxs = 13
    rxsi : U16
    rxsi = 3
    m : U16
    m = 62169
    xs : U16
    xs = 11
    pcgRxsMXs state rxs rxsi m xs

# See `pcg_output_rxs_m_xs_32_32` (on line 176?) in the C++ header.
growSeed32 : Seed32 -> U32
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

# See `pcg_oneseq_8_step_r` (line 409?) in the above C++ header
updateSeed8 : Seed8 -> Seed8
updateSeed8 = \Seed8 state ->
    multiplier : U8
    multiplier = 141
    # TODO: Replace this with user-supplied?
    increment : U8
    increment = 77
    Seed8 (pcgUpdateState state multiplier increment)

# See `pcg_oneseq_16_step_r` (line 456?) in the above C++ header
updateSeed16 : Seed16 -> Seed16
updateSeed16 = \Seed16 state ->
    multiplier : U16
    multiplier = 12829
    # TODO: Replace this with user-supplied?
    increment : U16
    increment = 47989
    Seed16 (pcgUpdateState state multiplier increment)

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
