# Randomness for Roc

A [Roc](https://roc-lang.org) library for random number generation

## Status

This is a work in progress.

Contributions & feedback are very welcome! :)

## Examples

```
app "simple_example"
    packages { pf: "../roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf


main =
    
    a = randNum (Random.seed32 42)
    b = a |> Random.next randNum

    _ <- await (line (Num.toStr a.value |> \x -> "a: \(x)"))
    _ <- await (line (Num.toStr b.value |> \x -> "b: \(x)"))
    
    line "The values will be the same on each run, because we use the same seed (42)."


randNum : Random.Generator Random.Seed32 U32
randNum = \seed ->
    Random.step seed (Random.u32 0 100)
```

See the `*.example.roc` files for more examples.

## Documentation

See [the library documentation site](JanCVanB.github.io/roc-random)
for more info about its API.

However,
[the single library file itself](Random.roc)
should be self-documenting.

## Goals

* An external API that is similar to that of
[Elm's `Random` library](https://github.com/elm/random)
* An internal implementation that is similar to that of
[Rust's `Rand` library](https://github.com/rust-random/rand)
* Compatible with every Roc platform
(though some platforms may provide poor/constant [seeding](#Seeding))
* Provides a variety of ergonomic abstractions

## Seeding

In order to receive a different sequence of outputs from this library
between executions of your application,
your Roc platform of choice must provide
a random/pseudorandom/varying seed.
Otherwise, your pure functions will be responsible
for providing `Random`'s pure functions with a constant seed
that will merely choose which predictable sequence you'll receive.
