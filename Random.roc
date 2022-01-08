interface Random
    exposes [
        Generation,
        Generator,
        Seed,
        int,
        last,
        next,
        one,
        step,
    ]
    imports []


Seed : U64
Generator a : [ @Generator (Seed -> Generation a) ]
Generation a : [ Tuple a Seed ]


after : Generator a, (a -> Generator b) -> Generator b
after = \@Generator generatorA, callback ->
    @Generator \seed1 ->
        Tuple value seed2 = generatorA seed1
        @Generator generatorB = callback value
        generatorB seed2

constant : a -> Generator a
constant = \x -> @Generator \seed -> Tuple x seed

one : Generator a, Seed -> a
one = \g, s ->
    when g s is
        Tuple value _ -> value

last : Generation *, Generator a -> a
last = \x, g ->
    when x is
        Tuple _ seed ->
            when g seed is
                Tuple value _ -> value

step : Seed, Generator a -> Generation a
step = \seed, g -> g seed


int : Int a, Int a -> Generator (Int a)
int = \a, b ->
    \seed ->
        # TODO: Replace this placeholder implementation with PCG.
        if (seed % 2 |> Result.withDefault 0) == 0 then
            Tuple a (seed + 1)
        else
            Tuple b (seed + 1)
