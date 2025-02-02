app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

# Print a list of 10 random numbers in the range 25-75 inclusive.
main! = \_ ->
    random_numbers
    |> List.map(Num.toStr)
    |> Str.joinWith("\n")
    |> \numbers_list_str -> Stdout.line!("$(numbers_list_str)")

numbers_generator : Random.Generator (List U32)
numbers_generator =
    Random.list(Random.bounded_u32(25, 75), 10)

random_numbers : List U32
random_numbers =
    { value: numbers } = Random.step(Random.seed(1234), numbers_generator)

    numbers

expect
    actual = random_numbers
    actual == [52, 34, 26, 69, 34, 35, 51, 74, 70, 39]
