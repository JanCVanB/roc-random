app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
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

main! = \_ ->
    { value: color } = Random.step(seed, color_generator)
    Stdout.line!("Color generated: $(Inspect.toStr(color))")
