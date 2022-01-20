# Randomness for Roc

A [Roc](https://roc-lang.org) library for random number generation

## Status

This is a work in progress.

Contributions & feedback are very welcome! :)

## Examples

```
app "simple_example"
    packages { pf: "./roc/examples/cli/platform" }
    imports [ pf.Stdout.{ line }, pf.Task.{ await }, Random ]
    provides [ main ] to pf

main =
    
    seed = Random.seed32 42  # `seed` contains the initial "randomness".
    int = Random.int 0 100   # `int` generates values from 0-100 (inclusive) and updates the seed.
    x = int seed             # x == { value: 9, seed: Seed32 -60952905 }
    y = x |> Random.next int # y == { value: 61, seed: Seed32 1561666408 }

    _ <- await (line (Num.toStr x.value |> \s -> "x: \(s)")) # This will print `x: 9`.
    _ <- await (line (Num.toStr y.value |> \s -> "y: \(s)")) # This will print `x: 61`.
    line "These values will be the same on every run, because we use a constant seed (42)."
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
