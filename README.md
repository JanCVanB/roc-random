# Randomness for Roc

A [Roc](https://github.com/roc-lang/roc) library for random number generation

Contributions & feedback are very welcome!

TODO:
- Add links to
- platforms and other community repos 
- that use this library,
- because this seems to be the unofficial standard for RNG in Roc!

## Examples

See the `examples/*.roc` files for various complete examples, but here is a minimal preview:

### Print a list of 10 random numbers in the range 25-75 inclusive

```roc
# Create a generator for numbers between 25-75 (inclusive).
generate_a_number = Random.bounded_u32 25 75

# Create a generator for lists of 10 numbers.
generate_ten_numbers = generate_a_number |> Random.list 10

# Initialise "randomness". (Bring Your Own source of noise.)
Random.seed 1234
|> Random.step generate_ten_numbers
|> .value
|> Inspect.toStr
|> Stdout.line!
```

## Documentation

See [the library documentation site](https://JanCVanB.github.io/roc-random/)
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
