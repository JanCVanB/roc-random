#!/usr/bin/env roc

app "simple_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    a = randNum (Random.seed32 42)
    b = a |> Random.next randNum

    _ <- await (line (Num.toStr x.value |> \s -> "x: \(s)")) # This will print `x: 9`.
    _ <- await (line (Num.toStr y.value |> \s -> "y: \(s)")) # This will print `x: 61`.
    line "These values will be the same on every run, because we use a constant seed (42)."


randNum : Random.Generator Random.Seed32 U32
randNum = \seed ->
    Random.step seed (Random.u32 0 100)
