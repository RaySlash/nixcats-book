# Getting Started

You can see all the available templates [here](./templates.md).
Here’s a simple walkthrough to set up nixCats:

1. **Clone the Template**:

    ```bash
    mkdir mynixcat && cd mynixcat
    nix flake init -t github:BirdeeHub/nixCats-nvim
    ```

2. **Edit `flake.nix`**:
    Add your plugins and categories.

    ```nix
    plugins = with pkgs.vimPlugins; [
        plenary-nvim
        nvim-treesitter.withAllGrammers
    ];
    ```

3. **Run Nix Shell**:
    ```bash
    nix develop
    ```

4. **Open Neovim**:
    ```bash
    nvim
    ```

