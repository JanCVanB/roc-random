app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Print a list of 10 random numbers in the range 25-75 inclusive.
main =
    randomNumbers
    |> List.map Num.toStr
    |> Str.joinWith "\n"
    |> \numbersListStr -> Stdout.line "$(numbersListStr)"

randomNumbers : List U32
randomNumbers =
    List.range { start: At 0, end: Before 100000 }
    |> List.walk { seed: Random.seed 1234, numbers: [] } \state, _ ->

        generator = Random.boundedU32 25 75
        output = Random.step state.seed generator

        {
            seed: output.state,
            numbers: List.append state.numbers output.value,
        }
    |> .numbers

expect
    actual = randomNumbers
    actual == [52, 34, 26, 69, 34, 35, 51, 74, 70, 39]
