# Overview

This chapter will explore the different architectural designs implemented within `nixCats-nvim` and will provide a concise understanding of the concepts involved. Later, we will explore a few ways to get started with `nixCats-nvim`.

## Investigation
There are many ways you could approach the way to handle neovim using nix. Lets go through them briefly, which will give you a clear idea of the reason why nixcats is superior to its alternatives. In order to have neovim in our NixOS system. We can add the `nixpkgs` option or the package itself. It would look something like this (use only one of these, setting both would most probably give you an infinite recursion):

```nix
programs.neovim.enable = true;

# OR

environment.systemPackages = with pkgs; [
    neovim
];
```

The nixpkgs derivations do already a great job in wrapping neovim itself and build from source. The 
next step obviously would be to add a few plugins to get our workflow going smoothly as we want to.

From the [Neovim Manual](https://neovim.io/doc/user/), we can deduce that neovim looks for the lua configuration `init.vim` or `init.lua` at `$HOME/.config/nvim`. We are only going to look at `init.lua` in this book. Our goal here is to use lua to configure neovim.

In NixOS, you can look at the available options for neovim at [search.nixos.org](https://search.nixos.org/options?channel=24.11&show=programs.neovim.enable&from=0&size=50&sort=relevance&type=packages&query=neovim), and immediately you can see that you are unable to use lua to configure the neovim with just the NixOS options available for neovim.

When using `home-manager`, you are now able to set the `init.lua` using the option `programs.neovim.extraLuaConfig` at [home-manager-options.extranix.com](https://home-manager-options.extranix.com/?query=neovim&release=master).
But, you are now only able to add the `init.lua` in the option.
If you wanted to modularize your configuration or use `ftplugin` feature of neovim,
your best option is to add every file using the `home-manager` option
```nix
home.".config/nvim/ftplugin/lua.lua".source = builtins.readFile ./ftplugin/lua.lua
```


> Usually, `$HOME` in Linux systems is defined as `/home/<user>`, where `<user>` represent the current logged-in user.

An example of module that override the nixpkgs neovim derivation to add extra plugins that are not available in `nixpkgs`:

```nix
# modules/nixos/neovim/default.nix
{ config, pkgs, ... }:

let
  easygrep = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "vim-easygrep";
    src = pkgs.fetchFromGitHub {
      owner = "dkprice";
      repo = "vim-easygrep";
      rev = "d0c36a77cc63c22648e792796b1815b44164653a";
      hash = "sha256-bL33/S+caNmEYGcMLNCanFZyEYUOUmSsedCVBn4tV3g=";
    };
  };
in
{
  environment.systemPackages = [
    (pkgs.neovim.override {
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            vim-go # already packaged plugin
            easygrep # custom package
          ];
          opt = [];
        };
        # ...
      };
    })
  ];
}
```

## Insights

The above module example works well but burdens the user with the responsibility to update the `rev` and `hash` manually in each derivation of custom vim plugins, that are not in nixpkgs.
Also, In case you wanted to call setup on any plugins that was fetched using nix, you would have to interpolate lua as nix
strings to achieve this such as `''${interpolate a string}'';`.

This interpolation of lua is pretty inconvenient to write for a couple of reasons but not limited to:

- User would not be able to use any LSP (Language Server Protocol) on the interpolated lua strings.
- Maintainability of code in strings is a horrible experience.

The ideal neovim configuration neovim would necessarily need a few feature to be maintainable:

- A way to write `lua` separately in a lua file and `nix` in its own file.
- Run our configuration outside of our system that have access to `nix` (CLI).
- Have multiple configuration profiles within a same configuration base.
- Our configuration should be exported* as `nixosModule`, `homeManagerModule`, `overlay` and `package`.
This enable users to integrate with any necessary system with ease.

Now lets enter the `nixcats` world. The next page would talk about the options and specific architectural pattern within nixcats.

> `*`: The exports could differ from template to template. Thus, make sure you choose a template that fits your need.
