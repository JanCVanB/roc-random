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
Generator a : Seed -> Generation a
Generation a : [ Tuple a Seed ]


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

next : Generation *, Generator a -> Generation a
next = \x, g ->
    when x is
        Tuple _ seed -> g seed

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
