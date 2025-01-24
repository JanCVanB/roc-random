app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/bi5zubJ-_Hva9vxxPq4kNx4WHX6oFs8OP6Ad0tCYlrY.tar.br",
    rand: "../package/main.roc",
}

import cli.Stdout
import rand.Random

Color : { red : U8, green : U8, blue : U8, alpha : U8 }

color_generator : Random.Generator Color
color_generator =
    { Random.chain <-
        red: Random.u8,
        green: Random.u8,
        blue: Random.u8,
        alpha: Random.u8,
    }

seed = Random.seed(12345)

main! = |_args|
    { value: color } = Random.step(seed, color_generator)
    Stdout.line!("Color generated: ${Inspect.to_str(color)}")
