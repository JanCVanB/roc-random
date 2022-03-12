#!/usr/bin/env roc

app "example_digits"
    packages { pf: "./roc/examples/interactive/cli-platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =

    a = (Random.i32 0 9) (Random.seed32 6)
    b = (Random.i32 0 9) (Random.seed32 6)

    c = (Random.u32 0 9) (Random.seed32 6)
    d = (Random.u32 0 9) (Random.seed32 6)

    e = (Random.i16 0 9) (Random.seed16 6)
    f = (Random.i16 0 9) (Random.seed16 6)

    g = (Random.u16 0 9) (Random.seed16 6)
    h = (Random.u16 0 9) (Random.seed16 6)

    i = (Random.i8 0 9) (Random.seed8 6)
    j = (Random.i8 0 9) (Random.seed8 6)

    k = (Random.u8 0 9) (Random.seed8 6)
    l = (Random.u8 0 9) (Random.seed8 6)

    m = (Random.u8 0 9) (Random.seed8 12)
    n = (Random.u8 0 9) (Random.seed8 12)

    o = n |> Random.next (Random.u8 0 9)
    p = n |> Random.next (Random.u8 0 9)

    q = p |> Random.next (Random.u8 0 9)
    r = p |> Random.next (Random.u8 0 9)

    _ <- await (line (Num.toStr a.value |> \s -> "a == 9 == \(s)"))
    _ <- await (line (Num.toStr b.value |> \s -> "b == 9 == \(s)"))
    _ <- await (line (Num.toStr c.value |> \s -> "c == 9 == \(s)"))
    _ <- await (line (Num.toStr d.value |> \s -> "d == 9 == \(s)"))
    _ <- await (line (Num.toStr e.value |> \s -> "e == 6 == \(s)"))
    _ <- await (line (Num.toStr f.value |> \s -> "f == 6 == \(s)"))
    _ <- await (line (Num.toStr g.value |> \s -> "g == 2 == \(s)"))
    _ <- await (line (Num.toStr h.value |> \s -> "h == 2 == \(s)"))
    _ <- await (line (Num.toStr i.value |> \s -> "i == 2 == \(s)"))
    _ <- await (line (Num.toStr j.value |> \s -> "j == 2 == \(s)"))
    _ <- await (line (Num.toStr k.value |> \s -> "k == 6 == \(s)"))
    _ <- await (line (Num.toStr l.value |> \s -> "l == 6 == \(s)"))
    _ <- await (line (Num.toStr m.value |> \s -> "m == 3 == \(s)"))
    _ <- await (line (Num.toStr n.value |> \s -> "n == 3 == \(s)"))
    _ <- await (line (Num.toStr o.value |> \s -> "o == 7 == \(s)"))
    _ <- await (line (Num.toStr p.value |> \s -> "p == 7 == \(s)"))
    _ <- await (line (Num.toStr q.value |> \s -> "q == 0 == \(s)"))
    _ <- await (line (Num.toStr r.value |> \s -> "r == 0 == \(s)"))
    line "These values will be the same on every run, because we use constant seeds."
