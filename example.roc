#!/usr/bin/env roc

app "example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    Point : { x : Int *, y : Int *, z : Int * }
    point : Random.Generator Point
    point = 
        x <- Random.after (Random.int 0 100)
        y <- Random.after (Random.int 0 100)
        z <- Random.after (Random.int 0 100)
        Random.constant { x, y, z }
    a = Random.one point 2 # Even seed ~ x==6
    b = Random.one point 3 # Odd seed ~ x==5
    c = Random.one point 4 # Even seed ~ x==6
    d = Random.step 6 point # Even seed, but...
        |> Random.last point # ... odd seed ~ x==5 (seed increments on each use)
    _ <- await (line (Num.toStr a.x)) # 6
    _ <- await (line (Num.toStr b.x)) # 5
    _ <- await (line (Num.toStr c.x)) # 6
    _ <- await (line (Num.toStr d.x)) # 5
    line ":)"
