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

## Home Manager

When using `home-manager`, you are able to link files into place.
```nix
home.".config/nvim/".source = ./mynvimconfig;
```

Whats the problem with this! Its great! I can download stuff with a neovim package manager and mason... right?

Well, you can try. But if you want treesitter grammers, you're also going to want this.

```nix
home.packages = with pkgs; [
  stdenv.cc.cc
];
```

And mason just isn't going to work on nixos, so youre going to want to swap that for just lspconfig and add those too.

```nix
home.packages = with pkgs; [
  stdenv.cc.cc
  nixd
  lua-language-server
  rust-analyzer
];
```

Uh oh!!!

How do we pass in info from nix into our configuration? I'm using agenix!

Well, now we have to probably write some stuff in nix. Lets change our approach and use the home manager module.

```nix
programs.neovim = {
  enable = true;
  plugins = with pkgs.vimPlugins [
    lze;
    {
      plugin = telescope-nvim;
      config = ''
        require("lze").load {
          "telescope.nvim",
          cmd = "Telescope",
        }
      '';
      type = "lua";
      optional = true;
    }
    {
      plugin = sweetie-nvim;
      config = ''
        require("lze").load {
          "sweetie.nvim",
          colorscheme = "sweetie",
        }
      '';
      type = "lua";
      optional = true;
    }
  ];
};
```

Oh no... This is all wrong... Where is our auto complete! Where did our directory go?

You think I'm going to write all my lua in nix strings just so that I can `"${interpolate}"` if I need to?

Also, this is tied to home manager! What if you don't want home manager on a machine?

What if you want to run it on another person's machine without putting your whole home-manager configuration on their computer?

# A naieve standalone approach

Lets try `pkgs.wrapNeovim` in a `flake`.

```nix
{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
  };
  outputs = { nixpkgs, neovim-nightly, ...}@inputs: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
  in {
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; };
      myNeovim = let
        luaRC = final.writeText "init.lua" ''
          local configdir = "${./mynvimconfig}";
          vim.opt.packpath:prepend(configdir)
          vim.opt.runtimepath:prepend(configdir)
          vim.opt.runtimepath:append(configdir .. "/after")
          if vim.fn.filereadable(configdir .. "/init.lua") == 1 then
            dofile(configdir .. "/init.lua")
          end
        '';
      in
      pkgs.wrapNeovim pkgs.neovim-unwrapped {
        configure = {
          customRC = ''lua dofile("${luaRC}")'';
          packages.all.start = with pkgs.vimPlugins; [ 
            nvim-treesitter.withAllGrammars
            lze
            telescope-nvim
          ];
          packages.all.opt = with pkgs.vimPlugins; [
          ];
        };
        extraMakeWrapperArgs = builtins.concatStringsSep " " [
          ''--prefix PATH : "${pkgs.lib.makeBinPath (with pkgs; [
            stdenv.cc.cc
            nixd
            lua-language-server
            rust-analyzer
          ])}"''
        ];
        extraLuaPackages = (_: []);
        extraPythonPackages = (_: []);
        withPython3 = true;
        extraPython3Packages = (_: []);
        withNodeJs = false;
        withRuby = true;
        vimAlias = false;
        viAlias = false;
        extraName = "";
      };
    in
    {
      default = myNeovim;
    });
  };
}
```

Well, this is kinda cool. We can run this from the command line, it pulls in our directory... It's pretty close to what we want.

But still... It could be better.

How do we pass info from nix into our directory?

The answer? Usually people just add a bunch of global variables.

Obviously that's not super ideal.

Also, every time we want to change it, we have to reload!

## What do we want?

The ideal neovim configuration would necessarily need a few feature to be maintainable:

- A way to write `lua` separately in a `lua` file and `nix` in its own file.
- A way to seamlessly pass extra arbitrary info from `nix` to our configuration, without creating a long list of `vim.g.global_variables`.
- Run our configuration outside of our system that have access to `nix` (CLI).
- Have utilities for easily installing plugins that aren't on `nixpkgs`.
- Have multiple configuration profiles within a same configuration base.
- Have a mode that allows editing `lua` and seeing the results without rebuilding via nix, assuming the required things are already installed.
- Our configuration should be exported* as `nixosModule`, `homeManagerModule`, `overlay` and `package`.

This would enable users to integrate with any necessary system with ease.

Now lets enter the `nixCats` world. The next pages will talk about the options and specific architectural pattern within `nixCats`.

> `*`: The exports could differ from template to template. Thus, make sure you choose a template that fits your need.
