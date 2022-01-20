#!/usr/bin/env roc

app "simple_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    seed = Random.seed 42     # `seed` stores the "randomness", initialized by the user/platform.
    int = Random.int 0 100    # `int` generates values from 0-100 (inclusive) and updates the seed.
    x = int seed              # x == { value: -25, seed: Seed32 -60952905 }
    y = x |> Random.next int  # y == { value: -74, seed: Seed32 1561666408 }

    _ <- await (line (Num.toStr x.value |> \s -> "x: \(s)")) # This will print `x: -25`.
    _ <- await (line (Num.toStr y.value |> \s -> "y: \(s)")) # This will print `x: -74`.
    line "These values will be the same on every run, because we use a constant seed (42)."