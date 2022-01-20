#!/usr/bin/env roc

app "digits_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =

    a = digit32 (Random.seed32 6)
    b = digit32 (Random.seed32 6)

    c = digit16 (Random.seed16 6)
    d = digit16 (Random.seed16 6)

    e = digit8 (Random.seed8 6)
    f = digit8 (Random.seed8 6)

    g = digit8 (Random.seed8 12)
    h = digit8 (Random.seed8 12)

    i = h |> Random.next digit8
    j = h |> Random.next digit8

    k = j |> Random.next digit8
    l = j |> Random.next digit8

    _ <- await (line (Num.toStr a.value |> \s -> "a: \(s)")) # This will print `a: 9`.
    _ <- await (line (Num.toStr b.value |> \s -> "b: \(s)")) # This will print `b: 9`.
    _ <- await (line (Num.toStr c.value |> \s -> "c: \(s)")) # This will print `c: 2`.
    _ <- await (line (Num.toStr d.value |> \s -> "d: \(s)")) # This will print `d: 2`.
    _ <- await (line (Num.toStr e.value |> \s -> "e: \(s)")) # This will print `e: 6`.
    _ <- await (line (Num.toStr f.value |> \s -> "f: \(s)")) # This will print `f: 6`.
    _ <- await (line (Num.toStr g.value |> \s -> "g: \(s)")) # This will print `g: 3`.
    _ <- await (line (Num.toStr h.value |> \s -> "h: \(s)")) # This will print `h: 3`.
    _ <- await (line (Num.toStr i.value |> \s -> "i: \(s)")) # This will print `i: 7`.
    _ <- await (line (Num.toStr j.value |> \s -> "j: \(s)")) # This will print `j: 7`.
    _ <- await (line (Num.toStr k.value |> \s -> "k: \(s)")) # This will print `k: 0`.
    _ <- await (line (Num.toStr l.value |> \s -> "l: \(s)")) # This will print `l: 0`.
    line " :)"


digit8 : Random.Generator Random.Seed8 U8
digit8 = Random.u8 0 9

digit16 : Random.Generator Random.Seed16 U16
digit16 = Random.u16 0 9

digit32 : Random.Generator Random.Seed32 U32
digit32 = Random.u32 0 9
