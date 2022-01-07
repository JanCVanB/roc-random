interface Random
    exposes [
        Generation,
        Generator,
        Seed,
        andThen,
        init,
        int,
        step,
    ]
    imports []


Seed : U64
Generator a : Seed -> Generation a
# TODO: Can we simplify this type? `x.value` is awkward.
Generation a : { value : a, seed : Seed }
Generate a : Generator a -> Generation a


# TODO: Can we automate seed caching/passing?
#       How does Elm do it?
#       This is not currently an abstraction above `step`.
# init : ({} -> Seed) -> Generate *
StatefulGenerator a o : StatelessGenerator a -> StatefulGeneration a o
StatefulGeneration a o : { value : a, seed: Seed, pfOutput : o }
InitConfig o : {
    getInitialSeed : {} -> Seed,
    postUpdatedSeed : Seed -> o,
    }
init : InitConfig o -> StatefulGenerator * o
init = \config ->
    initialSeed = config.getInitialSeed {}
    \g ->
        { value, seed } = g initialSeed
        pfOutput = config.postUpdatedSeed seed
        { value, seed, pfOutput }



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


andThen : Generation *, Generator a -> Generation a
andThen = \x, g -> g x.seed
