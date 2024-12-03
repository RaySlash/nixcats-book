# Architecture

> Copy of [https://nixcats.org/nixCats_installation.html#nixCats.templates](https://nixcats.org/nixCats_installation.html#nixCats.templates)

For the following 100 lines, it is most effective to cross reference with a template!

First choose a path for `luaPath` as your new neovim directory to be loaded into
the store.

Then in `categoryDefinitions`:
You have a SET to add LISTS of plugins to the packpath (one for both
`pack/*/start` and `pack/*/opt`), a SET to add LISTS of things to add to the path,
a set to add lists of shared libraries,
a set of lists to add... pretty much anything.
Full list of these sets is at `:h nixCats.flake.outputs.categories`

Those lists are in sets, and thus have names.

You do this in `categoryDefintions`, which is a function provided a pkgs set.
It also receives the values from `packageDefintions` of the package it is being called with.
It returns those sets of things mentioned above.

`packageDefintions` is a set, containing functions that also are provided a
pkgs set. They return a set of categories you wish to include.
If, from your `categoryDefintions`, you returned:

```nix
  startupPlugins = {
    general = [
      pkgs.vimPlugins.lz-n
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.telescope
      # etc ...
    ];
  };
```

In your `packageDefintions`, if you wanted to include it in a package named
`myCoolNeovimPackage`, launched with either `myCoolNeovimPackage` or `vi`,
you could have:

```nix
    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      myCoolNeovimPackage = { pkgs, ... }@misc: {
        settings = {
          aliases = [ "vi" ];
        };
        categories = {
          # setting the value to true will include it!
          general = true;
          # yes you can nest them
        };
      };
      # You can return as many packages as you want
    };
    defaultPackageName = "myCoolNeovimPackage";
```

They also return a set of settings, for the full list see `:h nixCats.flake.outputs.settings`

Then, a package is exported and built based on that using the nixCats builder
function, and various flake exports such as modules based on your config
are made using utility functions provided.
The templates take care of that part for you, just add stuff to lists.

But the cool part. That set of settings and categories is translated verbatim
from a nix set to a lua table, and put into a plugin that returns it.
It also passes the full set of plugins included via nix and their store paths
in the same manner. This gives full transparency to your neovim of everything
in nix. Passing extra info is rarely necessary outside of including categories
and setting settings, but it can be useful, and anything other than nix
functions may be passed. You then have access to the contents of these tables
anywhere in your neovim, because they are literally a set hard-coded into a
lua file on your runtimpath.

You may use the `:NixCats` user command to view these
tables for your debugging. There is a global function defined that
makes checking subcategories easier. Simply call `nixCats('the.category')!`
It will return the nearest parent category value, but nil if it was a table,
because that would mean a different sub category was enabled, but this one was
not. It is simply a getter function for the table `require('nixCats').cats`
see `:h nixCats` for more info.

That is what enables full transparency of your nix configuration
to your neovim! Everything you could have needed to know from nix
is now easily passed, or already available, through the nixCats plugin!

It has a shorthand for importing plugins that aren't on nixpkgs, covered in
`:h nixCats.flake.inputs` and the templates set up the outputs for you.
Info about those outputs is detailed in `nixCats.flake.outputs.exports`
You can also add overlays accessible to the pkgs object above, and set config
values for it, how to do that is at the top of the templates, and covered in
help at `:h nixCats.flake.outputs.overlays` and `:h nixCats.flake.outputs.overlays`

It also has a template containing some lua functions that can allow you
to adapt your configuration to work without nix. For more info see `:h
nixCats.luaUtils` It contains useful functions,
such as "did nix load neovim" and "if not nix do this, else do that"
It also contains a simple wrapper for `lazy.nvim` that does the `rtp` reset
properly, and then can be used to tell lazy not
to download stuff in an easy to use fashion.

The goal of the starter templates is so that the usage at the start can be as simple
as adding plugins to lists and calling `require('theplugin').setup()`
Most further complexity is optional, and very complex things can be achieved
with only minor changes in nix, and some `nixCats('something')` calls.
You can then import the finished package, and reconfigure it again
without duplication using the override function! see `:h nixCats.overriding`.
