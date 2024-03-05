# WiktorCoin

This project implements sample coins based on the [Move tutorial](https://github.com/move-language/move/tree/main/language/documentation/tutorial).

## Infrastructure

One addition over the tutorial is automatic CI configuration to build and test the coin and serves as a test for both this sample project and Move tooling.

The CI infrastructure, which includes building, testing, proving with Boogie/Z3 and test coverage summary can be executed locally with:

```sh
docker build .
```

(Append `--progress=plain` when using Build X).

## More

See [First impressions of the Move programming language](https://brson.github.io/2022/09/21/move-impressions) for more details about Move.

## Note

This is a work in progress!
