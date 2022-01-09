#!/usr/bin/env roc

app "test"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await } ]
    provides [ main ] to pf

main =
    _ <- await (line "")
    a : Nat -> Nat
    a = \x -> x
    b : (Nat -> Nat) -> Nat
    b = \x -> x 6
    c = b a
    d = Num.toStr c
    line d
