app [main!] {
    # TODO replace with release URL
    cli: platform "../../basic-cli/platform/main.roc",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Seed value to generate random numbers
seed = Random.seed(1234)

# Generate a random number in the range 25-75 inclusive and convert it to a Str
generator = Random.bounded_u32(25, 75) |> Random.map(Num.to_str)

main! = \_args ->
    { value } = Random.step(seed, generator)

    Stdout.line!("Random number is ${value}")

expect Random.step(seed, generator) |> .value == "52"
