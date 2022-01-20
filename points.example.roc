#!/usr/bin/env roc

app "points_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    a = pointGen (Random.seed32 42)
    b = a |> Random.next pointGen

    _ <- await (line (Num.toStr a.value.x |> \s -> "a.x == 9 == \(s)"))
    _ <- await (line (Num.toStr a.value.y |> \s -> "a.y == 61 == \(s)"))
    _ <- await (line (Num.toStr b.value.x |> \s -> "b.x == 7 == \(s)"))
    _ <- await (line (Num.toStr b.value.y |> \s -> "b.y == 53 == \(s)"))
    line "These values will be the same on every run, because we use a constant seed (42)."


Point a : { x : a, y : a }


pointGen : Random.Generator Random.Seed32 (Point U32)
pointGen = \seed ->
    # TODO: remove unnecessary type definitions (min: U32...) once #2336 is fixed
    min: U32
    min = 0
    max: U32
    max = 100

    x = Random.step seed (Random.u32 min max)

    # x.seed is passed on to get a new random number
    y = Random.step x.seed (Random.u32 min max)

    { value: { x: x.value, y: y.value }, seed: y.seed }
