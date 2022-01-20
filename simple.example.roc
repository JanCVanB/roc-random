#!/usr/bin/env roc

app "simple_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    seed = Random.seed32 42  # `seed` contains the initial "randomness".
    int = Random.int 0 100   # `int` generates values from 0-100 (inclusive) and updates the seed.
    x = int seed             # x == { value: 9, seed: Seed32 -60952905 }
    y = x |> Random.next int # y == { value: 61, seed: Seed32 1561666408 }

    _ <- await (line (Num.toStr x.value |> \s -> "x: \(s)")) # This will print `x: 9`.
    _ <- await (line (Num.toStr y.value |> \s -> "y: \(s)")) # This will print `x: 61`.
    line "These values will be the same on every run, because we use a constant seed (42)."
