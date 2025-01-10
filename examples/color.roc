app [main!] {
    # TODO replace with release URL
    cli: platform "../../basic-cli/platform/main.roc",
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

main! = \_args ->
    { value: color } = Random.step(seed, color_generator)
    Stdout.line!("Color generated: $(Inspect.to_str(color))")
