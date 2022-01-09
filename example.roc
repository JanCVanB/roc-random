#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    Point : Int *
    point : Random.Generator Point
    point = 
        # Random.after 1 2
        # x = \_ -> 6
        # Random.after (\_ -> x {}) (\_ -> x {})
        x = \seed -> { value: "x", seed }
        Random.after (Generator \s -> x s) (\_ -> (Generator \s -> x s))
        # x = Random.Generator \seed -> { value: "x", seed }
        # Random.after (\_ -> x 6) (\_ -> (\s -> x s))
        # x <- Random.after (Random.int 0 100)
        # Random.int x x
    a = Random.one point 6
    _ <- await (line (Num.toStr a))
    line ":)"
