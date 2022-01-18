#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    point = \seed ->
        x = Random.step seed (Random.u32 10 19)
        # TODO: Add `point.y : U64` when `Random.u64` is ready.
        # TODO: Add `point.z : U128` when `Random.u128` is ready.
        # TODO: Add `point.x4? : I32` when `Random.i32` is ready.
        # TODO: Add `point.x5? : I64` when `Random.i64` is ready.
        # TODO: Add `point.x6? : I128` when `Random.i128` is ready.
        { value: { x: x.value }, seed: x.seed }
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
