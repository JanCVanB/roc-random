# Randomness for Roc

A [Roc](https://roc-lang.org) library for random number generation

## Status

This is a work in progress.

Contributions & feedback are very welcome! :)

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
