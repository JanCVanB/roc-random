#!/usr/bin/env roc

app "example_complex"
    packages { pf: "./roc/examples/interactive/cli-platform/main.roc" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    a = point (Random.seed 36)
    b = a |> Random.next point

    _ <- await (line (Num.toStr a.value.x |> \s -> "a.x ==   24 ==   \(s)"))
    _ <- await (line (Num.toStr a.value.y |> \s -> "a.y ==   37 ==   \(s)"))
    _ <- await (line (Num.toStr a.value.z |> \s -> "a.z ==   61 ==   \(s)"))
    _ <- await (line (Num.toStr a.value.t |> \s -> "a.t ==  -47 ==  \(s)"))
    _ <- await (line (Num.toStr b.value.x |> \s -> "b.x ==   90 ==   \(s)"))
    _ <- await (line (Num.toStr b.value.y |> \s -> "b.y == -100 == \(s)"))
    _ <- await (line (Num.toStr b.value.z |> \s -> "b.z ==   44 ==   \(s)"))
    _ <- await (line (Num.toStr b.value.t |> \s -> "b.t ==    6 ==    \(s)"))
    line "These values will be the same on every run, because we use a constant seed."


# Complex `Generator`s can be created by chaining primitive `Generator`s.
Point a : { x : a, y : a, z : a, t : a }
point : Random.Generator U32 (Point I32)
point = \state ->
    min = -100
    max = 100
    # Primitive generator constructors are included in `Random`.
    i = Random.int min max
    # The initial seed is used to generate the first generation.
    x = Random.step state i
    # The updated seed is passed forward to generate the next generation.
    y = Random.step x.state i
    # `Random.next` is just a convenience method for passing a seed (equivalent to `Random.step y.seed i`).
    z = Random.next y i
    # `Random.next` pairs nicely with the pipe operator (equivalent to `Random.step z.seed i`).
    t = z |> Random.next i
    # Return a record with `.seed` and `.value` for compatibility.
    { value: { x: x.value, y: y.value, z: z.value, t: t.value }, state: t.state }
