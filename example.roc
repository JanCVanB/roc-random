#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

# TODO: Use other generators when they're ready.
main =
    a = pointU8 (Random.seed8 1)
    b = pointU8 (Random.seed8 1)
    c = pointU32 (Random.seed32 1)
    d = pointU32 (Random.seed32 1)
    e = pointU16 (Random.seed16 1)
    f = pointU16 (Random.seed16 1)
    g = pointU16 (Random.seed16 2)
    h = pointU16 (Random.seed16 2)
    i = h |> Random.next pointU16
    j = h |> Random.next pointU16
    k = j |> Random.next pointU16
    l = j |> Random.next pointU16
    _ <- await (line (Num.toStr a.value.x |> \x -> "a: \(x)"))
    _ <- await (line (Num.toStr b.value.x |> \x -> "b: \(x)"))
    _ <- await (line (Num.toStr c.value.x |> \x -> "c: \(x)"))
    _ <- await (line (Num.toStr d.value.x |> \x -> "d: \(x)"))
    _ <- await (line (Num.toStr e.value.x |> \x -> "e: \(x)"))
    _ <- await (line (Num.toStr f.value.x |> \x -> "f: \(x)"))
    _ <- await (line (Num.toStr g.value.x |> \x -> "g: \(x)"))
    _ <- await (line (Num.toStr h.value.x |> \x -> "h: \(x)"))
    _ <- await (line (Num.toStr i.value.x |> \x -> "i: \(x)"))
    _ <- await (line (Num.toStr j.value.x |> \x -> "j: \(x)"))
    _ <- await (line (Num.toStr k.value.x |> \x -> "k: \(x)"))
    _ <- await (line (Num.toStr l.value.x |> \x -> "l: \(x)"))
    line " :)"

Point a : { x : a, y : a, z : a }

pointU8 : Random.Generator Random.Seed8 (Point U8)
pointU8 = \seed ->
    x = Random.step seed (Random.u8 10 19)
    y = Random.step x.seed (Random.u8 20 29)
    z = Random.step y.seed (Random.u8 30 39)
    { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }

pointU16 : Random.Generator Random.Seed16 (Point U16)
pointU16 = \seed ->
    x = Random.step seed (Random.u16 10 19)
    y = Random.step x.seed (Random.u16 20 29)
    z = Random.step y.seed (Random.u16 30 39)
    { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }

pointU32 : Random.Generator Random.Seed32 (Point U32)
pointU32 = \seed ->
    x = Random.step seed (Random.u32 10 19)
    y = Random.step x.seed (Random.u32 20 29)
    z = Random.step y.seed (Random.u32 30 39)
    { value: { x: x.value, y: y.value, z: z.value }, seed: z.seed }
