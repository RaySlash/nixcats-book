# Architecture

This chapter will explore the different architectural designs implemented within `nixCats-nvim` and will provide a concise understanding of the concepts involved. Lets begin uncovering each parts by starting to identify the different parts within neovim configuration.

## Overview

At its core, nixCats is a modular and customizable Neovim configuration framework built with Nix. It separates plugin and dependency management _(handled by Nix)_ from the actual Neovim configuration _(written in Lua)_. The main goals of nixCats are:
- **Seamless integration of Nix and Lua:**
        Nix is used for downloading and building dependencies.
        Lua is used for configuration within Neovim’s typical directory structure.

- **Portability and Scalability:**
        Support multiple configurations and environments using the same codebase.
        Enable environment-specific customization using categories.

- **Ease of use and flexibility:**
        Allow new users to get started quickly while providing advanced features for experienced users.

The following shows the flow of data from nix to lua in neovim:
```hs
(Nix-Dependencies) → (NixCats-Messaging) → (Lua-Configuration) → (Neovim-Environment)
````

## Core Features

### nixCats Messaging System

The **nixCats messaging system** bridges the gap between Nix and Lua. It allows the passing of data (e.g., plugin names, configuration flags, or runtime dependencies) from Nix into Lua. This ensures you don’t need to write Lua within Nix files, keeping both systems cleanly separated.

**How it works**:  
1. Nix generates a Lua table based on the configuration defined in `flake.nix`.  
2. The Lua table is saved into a `.lua` file (e.g., `plugin/nixCats.lua`).  
3. This table is accessible in Neovim using the `nixCats` function.

**Example**:  

```nix
# flake.nix
nixCatsUtils.packageDefinitions = {
  exampleConfig = {
    startupPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-treesitter
    ];
    lspsAndRuntimeDeps = [ "pyright" ];
  };
};
```

Generates the Lua table:

```lua
-- plugin/nixCats.lua
return {
  exampleConfig = {
    startupPlugins = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    lspsAndRuntimeDeps = { "pyright" },
  },
}
```

In Lua:

```lua
local nixCats = require('nixCats')
if nixCats("exampleConfig.startupPlugins") then
  -- Load plugin-specific configurations
end
```

---

### Category System

The **category system** enables fine-grained control of plugins and configurations across different environments. Categories are logical groups of plugins or features (e.g., `ide`, `minimal`, `python`, `git`). You can enable or disable these categories within Nix, and the changes are automatically reflected in Lua.

**Use Case**:  
Imagine you want a lightweight configuration for terminal sessions and a full-featured IDE setup for development.

**Nix Configuration**:

```nix
packageDefinitions = {
  ide = {
    startupPlugins = with pkgs.vimPlugins; [ 
        plenary-nvim
        telescope-nvim
    ];
    categories = { ide = true };
  };
  minimal = {
    startupPlugins = with pkgs.vimPlugins; [ vim-easy-align ];
    categories = { ide = false };
  };
};
```

**Lua Code**:

```lua
local nixCats = require('nixCats')

-- Check if a plugin is enabled in the current environment
if nixCats("ide") then
  require('telescope').setup {}
end
```

---

### Multiple Configurations

nixCats supports managing **multiple configurations** within the same project. You can define multiple entries in `packageDefinitions` for different purposes, such as:

1. A **development environment** with IDE features.
2. A **lightweight setup** for editing configuration files.

**Example**:

```nix
packageDefinitions = {
  fullIde = {
    startupPlugins = with pkgs.vimPlugin; [ coc-nvim ];
    wrapRc = true;
  };
  minimal = {
    startupPlugins = with pkgs.vimPlugin; [ vim-commentary ];
    wrapRc = false;
  };
};
```

---

## Advanced Features

### Dynamic Configurations with Categories

```lua
-- Example of using categories dynamically in Lua
if nixCats("python.ide") then
  require('lspconfig').pyright.setup {}
end
```

### Managing Dependencies  

- Use the `lspsAndRuntimeDeps` field to include tools like `pyright` or `rust-analyzer` in your configuration.

---

## Challenges and Solutions

### Issue: Mason Compatibility  
Mason.nvim doesn’t work on NixOS due to path issues.

**Solution**:  
Use `lspsAndRuntimeDeps` in `flake.nix` to install LSPs.

---

## Conclusion

nixCats simplifies and enhances Neovim configuration management using the power of Nix. Whether you're a beginner or an advanced user, its modular architecture, category system, and Lua messaging enable a smooth and scalable development experience.

