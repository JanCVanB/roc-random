# Randomness for Roc

A [Roc](https://github.com/roc-lang/roc) library for random number generation

## Status

Forked from [JanCVanB/roc-random](https://github.com/JanCVanB/roc-random), updated to build package and documentation, and do some maintenance.

This works, but there's much more it could do. Contributions & feedback are very welcome!

## Examples

```roc
import cli.Stdout
import rand.Random

# Print a list of 10 random numbers in the range 25-75 inclusive.
main! = \_args ->
    random_numbers
    |> List.map(Num.to_str)
    |> Str.join_with("\n")
    |> \numbers_list_str -> Stdout.line!("$(numbers_list_str)")

numbers_generator : Random.Generator (List U32)
numbers_generator =
    Random.list(Random.bounded_u32(25, 75), 10)

random_numbers : List U32
random_numbers =
    # we can ignore the updated seed value and just return the generated numbers
    { value: numbers } = Random.step(Random.seed(1234), numbers_generator)

    numbers

expect
    actual = random_numbers
    actual == [52, 34, 26, 69, 34, 35, 51, 74, 70, 39]
```

See the `examples/*.roc` files for more examples.

## Documentation

See [the library documentation site](https://lukewilliamboswell.github.io/roc-random/)
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
