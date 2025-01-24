app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/bi5zubJ-_Hva9vxxPq4kNx4WHX6oFs8OP6Ad0tCYlrY.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Seed value to generate random numbers
seed = Random.seed(1234)

# Generate a random number in the range 25-75 inclusive and convert it to a Str
generator =
    Random.bounded_u32(25, 75)
    |> Random.map(Num.to_str)

main! = |_args|
    { value } = Random.step(seed, generator)

    Stdout.line!("Random number is ${value}")

expect Random.step(seed, generator) |> .value == "52"
