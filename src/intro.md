# Introduction

Welcome to `NixCats Book`, a comprehensive guide crafted to help Neovim users transition to the Nix way of configuration. This book is designed to provide clarity and simplicity, allowing users to embrace Nix without losing control over their configurations by burying them with unmaintainable code.

NixCats _(aka. nixCats-nvim)_ bridges the gap for Neovim users by defining practical rules and patterns for configuring Neovim using Lua, ensuring your setup remains both declarative and maintainable. The goal is to make use of the declarative and reproducible nature of Nix with neovim configuration, empowering you to make full use of the text editor without hassles. NixCats follow the idea that _"You configure once and forget about it"_.

Whether you're new to Nix or a seasoned user looking to refine your approach, this guide will be your companion in building a robust, clean, and efficient Neovim configuration.

## Prerequisites

Before you get started with this book, it is assumed that you have a moderate knowledge of:
 - [Lua](https://www.lua.org/) programming language  
 - [Nix](https://nixos.org/) programming language 
 - [Git](https://git-scm.com/) Version Control System
 - [Neovim](https://neovim.io/doc/user/lua.html) configuration using Lua 

 If you feel like you lack knowledge in certain areas within the above mentioned, it is recommended to have a look at respective resources.  A few resources are mentioned in the [References](./references.md) Chapter for you to get started.
 > Additionally, the sub-chapters introduce about few concepts for absolute beginners in lua and nix. Feel free to skip to [Architecture](./architecture.md) if you are well versed with these.

## Terminology

- __Flakes:__ An experimental feature within Nix that allows users to grab resources from the web as `inputs` and can provide `output` of the packaged application. You can read more about flakes in [here](https://nixos.wiki/wiki/flakes)

- __Flake-Parts:__ A distributed framework for writing Nix flakes which is a direct lightweight replacement of the Nix flake [schema](https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake.html#flake-format)

- __Modules__ *(aka. Flake Modules)*__:__ Flakes are configuration. The module system lets you refactor configuration into modules that can be shared.
