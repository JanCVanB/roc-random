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

    q = (Random.u8 0 9) (Random.seed8Variant 12 1)
    r = (Random.u8 0 9) (Random.seed8Variant 12 111)

    s = q |> Random.next (Random.u8 0 9)
    t = r |> Random.next (Random.u8 0 9)

    _ <- await (line (Num.toStr a.value |> \x -> "a == 9 == \(x)"))
    _ <- await (line (Num.toStr b.value |> \x -> "b == 9 == \(x)"))
    _ <- await (line (Num.toStr c.value |> \x -> "c == 9 == \(x)"))
    _ <- await (line (Num.toStr d.value |> \x -> "d == 9 == \(x)"))
    _ <- await (line (Num.toStr e.value |> \x -> "e == 6 == \(x)"))
    _ <- await (line (Num.toStr f.value |> \x -> "f == 6 == \(x)"))
    _ <- await (line (Num.toStr g.value |> \x -> "g == 2 == \(x)"))
    _ <- await (line (Num.toStr h.value |> \x -> "h == 2 == \(x)"))
    _ <- await (line (Num.toStr i.value |> \x -> "i == 2 == \(x)"))
    _ <- await (line (Num.toStr j.value |> \x -> "j == 2 == \(x)"))
    _ <- await (line (Num.toStr k.value |> \x -> "k == 6 == \(x)"))
    _ <- await (line (Num.toStr l.value |> \x -> "l == 6 == \(x)"))
    _ <- await (line (Num.toStr m.value |> \x -> "m == 3 == \(x)"))
    _ <- await (line (Num.toStr n.value |> \x -> "n == 3 == \(x)"))
    _ <- await (line (Num.toStr o.value |> \x -> "o == 7 == \(x)"))
    _ <- await (line (Num.toStr p.value |> \x -> "p == 7 == \(x)"))
    _ <- await (line (Num.toStr q.value |> \x -> "q == 3 == \(x)"))
    _ <- await (line (Num.toStr r.value |> \x -> "r == 3 == \(x)"))
    _ <- await (line (Num.toStr s.value |> \x -> "s == 0 == \(x)"))
    _ <- await (line (Num.toStr t.value |> \x -> "t == 5 == \(x)"))
    line "These values will be the same on every run, because we use constant seeds."
