#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ Gen, pf.Stdout.{ line }, pf.Task.{ await } ]
    provides [ main ] to pf

main =
    point = \seed ->
        x = Gen.step seed (Gen.int 6 5) # Even/odd seed chooses x==6 vs. x==5
        y = Gen.step x.seed (Gen.int 4 3)
        z = Gen.step y.seed (Gen.int 2 1)
        { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }
    a = point 2 # Even seed ~ x==6
    b = point 4 # Even seed ~ x==6
    c = point 6 # Even seed, but...
        |> Gen.next point # ... odd seed ~ x==5 (seed increments on each use)
    d = point 7 # Odd seed ~ x==5
    _ <- await (line (Num.toStr a.value.x)) # 6
    _ <- await (line (Num.toStr b.value.x)) # 6
    _ <- await (line (Num.toStr c.value.x)) # 5
    _ <- await (line (Num.toStr d.value.x)) # 5
    line ":)"
