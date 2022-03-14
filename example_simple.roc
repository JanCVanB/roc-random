#!/usr/bin/env roc

app "example_simple"
    packages { pf: "./roc/examples/interactive/cli-platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    state = Random.seed 42    # `state` stores the "randomness", initialized by the user/platform.
    int = Random.int 0 100    # `int` generates values from 0-100 (inclusive) and updates the state.
    x = int state             # x == { value: 9, state: { value: -60952905, ... } }
    y = x |> Random.next int  # y == { value: 61, state: { value: 1561666408, ... } }

    _ <- await (line (Num.toStr x.value |> \s -> "x: \(s)")) # This will print `x: 9`.
    _ <- await (line (Num.toStr y.value |> \s -> "y: \(s)")) # This will print `x: 61`.
    line "These values will be the same on every run, because we use a constant seed (42)."
