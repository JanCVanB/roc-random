app "example_complex_with_backpassing"
    packages { pf: "roc/examples/interactive/cli-platform/main.roc" }
    imports [pf.Stdout.{ line }, pf.Task.{ await }, RandomB]
    provides [main] to pf

main =
    a = point (RandomB.seed 36)
    b = a |> RandomB.next point

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
point : RandomB.Generator (Point I32) (RandomB.State U32)
point =
    min = -100
    max = 100

    # Primitive generator constructors are included in `Random`.
    x <- RandomB.int min max
    y <- RandomB.int min max
    z <- RandomB.int min max
    t <- RandomB.int min max
    \state -> { value: { x, y, z, t }, state }
