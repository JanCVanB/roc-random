# !/usr/bin/env roc
app "example_simple"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.3.1/97mY3sUwo433-pcnEQUlMhn-sWiIf_J9bPhcAFZoqY4.tar.br" }
    imports [
        pf.Stdout,
        Random,
    ]
    provides [main] to pf

main =

    # Initialise "randomness"
    initialSeed = Random.seed16 42

    # Create a generator for values from 0-100 (inclusive)
    u16 = Random.u16 0 100

    # Create a list of random numbers
    result =
        List.range { start: At 1, end: At 1000 }
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

    Stdout.line "Random numbers are: \(numbersListStr)"
