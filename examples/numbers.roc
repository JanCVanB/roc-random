app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/bi5zubJ-_Hva9vxxPq4kNx4WHX6oFs8OP6Ad0tCYlrY.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Print a list of 10 random numbers in the range 25-75 inclusive.
main! = |_args|
    random_numbers
    |> List.map(Num.to_str)
    |> Str.join_with("\n")
    |> Stdout.line!

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
