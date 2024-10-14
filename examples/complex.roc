app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

main =
    a = point (Random.seed 36)
    b = a |> Random.next point
    Stdout.line! (Num.toStr a.value.x |> \s -> "a.x == -59 == $(s)")
    Stdout.line! (Num.toStr a.value.y |> \s -> "a.y == -62 == $(s)")
    Stdout.line! (Num.toStr a.value.z |> \s -> "a.z == -64 == $(s)")
    Stdout.line! (Num.toStr a.value.t |> \s -> "a.t ==   4 ==   $(s)")
    Stdout.line! (Num.toStr b.value.x |> \s -> "b.x ==  82 ==  $(s)")
    Stdout.line! (Num.toStr b.value.y |> \s -> "b.y ==  78 ==  $(s)")
    Stdout.line! (Num.toStr b.value.z |> \s -> "b.z == -64 == $(s)")
    Stdout.line! (Num.toStr b.value.t |> \s -> "b.t == -20 == $(s)")
    Stdout.line! "These values will be the same on every run, because we use a constant seed."

# Complex `Generator`s can be created by chaining primitive `Generator`s.
Point : { t : I32, x : I32, y : I32, z : I32 }

point : Random.Generator U32 Point
point =
    min = -100
    max = 100
    boundedInt = Random.int min max

    { Random.chain <-
        x: boundedInt,
        y: boundedInt,
        z: boundedInt,
        t: boundedInt,
    }
