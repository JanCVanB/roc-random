#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    point = \seed ->
        x = Random.step seed (Random.int 6 5) # Even/odd seed chooses x==6 vs. x==5
        y = Random.step x.seed (Random.int 4 3)
        z = Random.step y.seed (Random.int 2 1)
        { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }
    a = point 2 # Even seed ~ x==6
    b = point 4 # Even seed ~ x==6
    c = point 6 # Even seed, but...
        |> Random.andThen point # ... odd seed ~ x==5 (seed increments on each use)
    d = point 7 # Odd seed ~ x==5
    nextSeed = 8
    getInitialSeed = \_ -> nextSeed
    postUpdatedSeed = \_ ->
        # Uhhh, can't mutate the cache...
        {}
    # TODO: When https://github.com/rtfeldman/roc/issues/2322 is resolved, use these lines instead:
    # generate = Random.init getSeed
    # e = generate point # Even seed ~ x==6
    # f = generate point # Even seed, but...
    #     |> Random.andThen point # ... odd seed ~ x==5 (seed increments on each use)
    e = (Random.init {getInitialSeed:getInitialSeed,postUpdatedSeed:postUpdatedSeed}) point # Even seed ~ x==6
    f = (Random.init {getInitialSeed:getInitialSeed,postUpdatedSeed:postUpdatedSeed}) point # Even seed, but...
        |> Random.andThen point # ... odd seed ~ x==5 (seed increments on each use)
    _ <- await (line (Num.toStr a.value.x)) # 6
    _ <- await (line (Num.toStr b.value.x)) # 6
    _ <- await (line (Num.toStr c.value.x)) # 5
    _ <- await (line (Num.toStr d.value.x)) # 5
    _ <- await (line (Num.toStr e.value.x)) # 6
    _ <- await (line (Num.toStr f.value.x)) # 5
    line ":)"
