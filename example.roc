#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    point = \seed ->
        # TODO: Test non-64-bit generators.
        x = Random.step seed (Random.u32 1 2)
        # y = Random.step x.seed (Random.i32 3 4)
        # z = Random.step y.seed (Random.int 5 6)
        z = Random.step x.seed (Random.int 5 6)
        # { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }
        { value: { x: x.value, z: z.value }, seed: z.seed }
    # TODO: Test non-32-bit seeds as well.
    a = point (Random.seed32 1)
    b = point (Random.seed32 1)
    c = point (Random.seed32 2)
    d = c |> Random.next point
    e = c |> Random.next point
    f = d |> Random.next point
    _ <- await (line (Num.toStr a.value.x))
    _ <- await (line (Num.toStr b.value.x))
    _ <- await (line (Num.toStr c.value.x))
    _ <- await (line (Num.toStr d.value.x))
    _ <- await (line (Num.toStr e.value.x))
    _ <- await (line (Num.toStr f.value.x))
    line ":)"
