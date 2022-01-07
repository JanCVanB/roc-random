interface Random
    exposes [
        Generation,
        Generator,
        Seed,
        int,
        next,
        step,
    ]
    imports []


Seed : U64
Generator a : Seed -> Generation a
# TODO: Can we simplify this type? `x.value` is awkward.
Generation a : { value : a, seed : Seed }


next : Generation *, Generator a -> Generation a
next = \x, g -> g x.seed

step : Seed, Generator a -> Generation a
step = \seed, g -> g seed


int : Int a, Int a -> Generator (Int a)
int = \a, b ->
    \seed ->
        # TODO: Replace this placeholder implementation with PCG.
        if (seed % 2 |> Result.withDefault 0) == 0 then
            { value: a, seed: seed + 1 }
        else
            { value: b, seed: seed + 1 }
