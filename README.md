# Randomness for Roc

A [Roc](https://github.com/roc-lang/roc) library for random number generation

## Status

Forked from [JanCVanB/roc-random](https://github.com/JanCVanB/roc-random), updated to build package and documentation, and do some maintenance.

This works, but there's much more it could do. Contributions & feedback are very welcome!

## Examples

```coffee
# Print a list of 10 random numbers in the range 25-75 inclusive.
main =

    # Initialise "randomness"
    initialSeed = Random.seed16 42

    # Create a generator for values from 25-75 (inclusive)
    u16 = Random.u16 25 75

    # Create a list of random numbers
    result =
        List.range { start: At 0, end: Before 10 }
        |> List.walk { seed: initialSeed, numbers: [] } \state, _ ->

            random = u16 state.seed
            seed = random.state
            numbers = List.append state.numbers random.value

            { seed, numbers }

    # Format as a string
    numbersListStr =
        result.numbers
        |> List.map Num.toStr
        |> Str.joinWith ","

    Stdout.line! "Random numbers are: \(numbersListStr)"
```

See the `examples/*.roc` files for more examples.

## Documentation

See [the library documentation site](https://lukewilliamboswell.github.io/roc-parser/)
for more info about its API.

## Goals

* An external API that is similar to that of
[Elm's `Random` library](https://github.com/elm/random)
* An internal implementation that is similar to that of
[Rust's `Rand` library](https://github.com/rust-random/rand)
* Compatible with every Roc platform
(though some platforms may provide poor/constant [seeding](#seeding))
* Provides a variety of ergonomic abstractions

## Seeding

In order to receive a different sequence of outputs from this library between executions of your application, your Roc platform of choice must provide a random/pseudorandom/varying seed.

Otherwise, your pure functions will be responsible for providing `Random`'s pure functions with a constant seed that will merely choose which predictable sequence you'll receive.
