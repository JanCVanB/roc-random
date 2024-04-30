# !/usr/bin/env roc
app "example_complex"
    packages { 
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
        rand: "../package/main.roc",
    }
    imports [
        cli.Task,
        cli.Stdout,
        rand.Random,
    ]
    provides [main] to cli

main =
    a = point (Random.seed 36)
    b = a |> Random.next point

    Stdout.line! (Num.toStr a.value.x |> \s -> "a.x == -59 == \(s)")
    Stdout.line! (Num.toStr a.value.y |> \s -> "a.y == -62 == \(s)")
    Stdout.line! (Num.toStr a.value.z |> \s -> "a.z == -64 == \(s)")
    Stdout.line! (Num.toStr a.value.t |> \s -> "a.t ==   4 ==   \(s)")
    Stdout.line! (Num.toStr b.value.x |> \s -> "b.x ==  82 ==  \(s)")
    Stdout.line! (Num.toStr b.value.y |> \s -> "b.y ==  78 ==  \(s)")
    Stdout.line! (Num.toStr b.value.z |> \s -> "b.z == -64 == \(s)")
    Stdout.line! (Num.toStr b.value.t |> \s -> "b.t == -20 == \(s)")

    Stdout.line! "These values will be the same on every run, because we use a constant seed."

# Complex `Generator`s can be created by chaining primitive `Generator`s.
Point : { t : I32, x : I32, y : I32, z : I32 }

point : Random.Generator U32 Point
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
