interface Random
    exposes [
        Generation,
        Generator,
        Seed,
        after,
        constant,
        int,
        # last,
        # next,
        one,
        # step,
    ]
    imports []


Seed : U64
Generator a : [ Generator (Seed -> Generation a) ]
Generation a : { value: a, seed: Seed}


after : Generator a, (a -> Generator b) -> Generator b
after = \_, _ ->
    Random.int 0 100

# after : Generator a, (a -> Generator b) -> Generator b
# after = \Generator generatorA, callback ->
#     Random.int 0 100

    # Generator b = callback 6
    # b

    # Generator \seed1 ->
        # { value, seed } = generatorA seed1
        # Generator generatorB = callback value
        # generatorB seed

constant : a -> Generator a
constant = \value -> Generator \seed -> { value, seed }

one : Generator a, Seed -> a
one = \Generator g, s ->
    { value } = g s
    value

# last : Generation *, Generator a -> a
# last = \x, g ->
#     when x is
#         Tuple _ seed ->
#             when g seed is
#                 Tuple value _ -> value

# step : Seed, Generator a -> Generation a
# step = \seed, g -> g seed


int : Int a, Int a -> Generator (Int a)
int = \x, y ->
    Generator \seed ->
        # TODO: Replace this placeholder implementation with PCG.
        if (seed % 2 |> Result.withDefault 0) == 0 then
            { value: x, seed: (seed + 1) }
        else
            { value: y, seed: (seed + 1) }
