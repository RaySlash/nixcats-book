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
    categoryDefinitions = { pkgs, ... }: {
        startupPlugins = {
            general = with pkgs.vimPlugins; [
                plenary-nvim
                nvim-treesitter.withAllGrammers
                # mkNvimPlugin build a plugin from flake input
                (mkNvimPlugin inputs.plugins-telescope "telescope") 
            ];
        };
    }
    
    packageDefinitions = {
        mynixcat = {pkgs, ...}: {
            settings = {
                wrapRc = true;
                aliases = ["vi" "vim" "nvim"];
                # Enable to use flake inputs to build nightly version of neovim
                # neovim-unwrapped =
                #       inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
            };
            categories = {
                general = true;
            };
            extra = {};
        };
    };
    
    defaultPackageName = "mynixcat";
    ```

    > See the comments in each templates for further reference.

3. **Open Neovim**:
    ```bash
    nix run .
    ```

