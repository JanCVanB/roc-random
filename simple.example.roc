app "simple_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

# TODO: Use U64 generator when ready.
main =
    
    a = randNum (Random.seed32 42)
    b = a |> Random.next randNum

    _ <- await (line (Num.toStr a.value |> \x -> "a: \(x)"))
    _ <- await (line (Num.toStr b.value |> \x -> "b: \(x)"))
    
    line "The values will be the same on each run, because we use the same seed (42)."


randNum : Random.Generator Random.Seed32 U32
randNum = \seed ->
    Random.step seed (Random.u32 0 100)