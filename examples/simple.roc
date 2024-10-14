app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Seed value to generate random numbers
seed = Random.seed 1234

# Generate a random number in the range 25-75 inclusive and convert it to a Str
generator = Random.boundedU32 25 75 |> Random.map Num.toStr

main =
    { value } = Random.step seed generator

    Stdout.line "Random number is $(value)"

expect Random.step seed generator |> .value == "52"
