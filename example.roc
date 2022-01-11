#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    point = \seed ->
        # TODO: Test non-64-bit generators.
        x = Random.step seed (Random.u64 1 2)
        y = Random.step x.seed (Random.i64 3 4)
        z = Random.step y.seed (Random.int 5 6)
        { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }
    # TODO: Test non-64-bit seeds.
    a = point (Random.seed 1)
    b = point (Random.seed 1)
    c = point (Random.seed 2)
    d = c |> Random.next point
    e = d |> Random.next point
    _ <- await (line (Num.toStr a.value.x))
    _ <- await (line (Num.toStr b.value.x))
    _ <- await (line (Num.toStr c.value.x))
    _ <- await (line (Num.toStr d.value.x))
    _ <- await (line (Num.toStr e.value.x))
    line ":)"
