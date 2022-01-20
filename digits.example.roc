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

    _ <- await (line (Num.toStr a.value |> \s -> "a == 9 == \(s)"))
    _ <- await (line (Num.toStr b.value |> \s -> "b == 9 == \(s)"))
    _ <- await (line (Num.toStr c.value |> \s -> "c == 2 == \(s)"))
    _ <- await (line (Num.toStr d.value |> \s -> "d == 2 == \(s)"))
    _ <- await (line (Num.toStr e.value |> \s -> "e == 6 == \(s)"))
    _ <- await (line (Num.toStr f.value |> \s -> "f == 6 == \(s)"))
    _ <- await (line (Num.toStr g.value |> \s -> "g == 3 == \(s)"))
    _ <- await (line (Num.toStr h.value |> \s -> "h == 3 == \(s)"))
    _ <- await (line (Num.toStr i.value |> \s -> "i == 7 == \(s)"))
    _ <- await (line (Num.toStr j.value |> \s -> "j == 7 == \(s)"))
    _ <- await (line (Num.toStr k.value |> \s -> "k == 0 == \(s)"))
    _ <- await (line (Num.toStr l.value |> \s -> "l == 0 == \(s)"))
    line "These values will be the same on every run, because we use constant seeds."


digit8 : Random.Generator Random.Seed8 U8
digit8 = Random.u8 0 9

digit16 : Random.Generator Random.Seed16 U16
digit16 = Random.u16 0 9

digit32 : Random.Generator Random.Seed32 U32
digit32 = Random.u32 0 9
