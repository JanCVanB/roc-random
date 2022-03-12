#!/usr/bin/env roc

app "points_example"
    packages { pf: "./roc/examples/interactive/cli-platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    a = pointGen (Random.seed 36)
    b = a |> Random.next pointGen

    _ <- await (line (Num.toStr a.value.x |> \s -> "a.x ==  24 ==  \(s)"))
    _ <- await (line (Num.toStr a.value.y |> \s -> "a.y ==  37 ==  \(s)"))
    _ <- await (line (Num.toStr b.value.x |> \s -> "b.x ==  61 ==  \(s)"))
    _ <- await (line (Num.toStr b.value.y |> \s -> "b.y == -47 == \(s)"))
    line "These values will be the same on every run, because we use a constant seed (36)."


Point a : { x : a, y : a }


pointGen : Random.Generator Random.Seed32 (Point I32)
pointGen = \seed ->
    # TODO: remove unnecessary type definitions (min: U32...) once #2336 is fixed
    min: I32
    min = -100
    max: I32
    max = 100

    x = Random.step seed (Random.int min max)

    # x.seed is passed on to get a new random number
    y = Random.step x.seed (Random.int min max)

    { value: { x: x.value, y: y.value }, seed: y.seed }
