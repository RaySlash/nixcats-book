# Project README

Visit: [rayslash.github.io/nixcats-book/](https://rayslash.github.io/nixcats-book/) 

This project is a flake. You can use `nix develop` or `direnv allow` if you have dir-env.

## Dev
There are several ways to render a book, but one of the easiest methods is to use the serve command, which will build your book and start a local webserver:
```shell
$ mdbook serve --open
```

The `--open` option will open your default web browser to view your new book. You can leave the server running even while you edit the content of the book, and mdbook will automatically rebuild the output and automatically refresh your web browser.

Check out the [CLI Guide](https://rust-lang.github.io/mdBook/cli/index.html) for more information about other mdbook commands and CLI options.

## Build
```shell
$ mdbook build
```
