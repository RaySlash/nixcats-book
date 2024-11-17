{
  description = "NixCats Book";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];

      systems = import inputs.systems;
      perSystem = { self', pkgs, system, ... }:
        let
          cargoToml = builtins.fromTOML (builtins.readFile ./book.toml);
          rust-toolchain =
            pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;

          buildDeps = with pkgs; [
            pkg-config
            coreutils
            mdbook
          ];

          mkPackage = rust-toolchain:
            pkgs.rustPlatform.buildRustPackage {
              inherit (cargoToml.package) version;
              name = "app";
              src = ./.;
              buildInputs = buildDeps;
              nativeBuildInputs = buildDeps + [ rust-toolchain ];
              cargoLock.lockFile = ./Cargo.lock;
              meta = {
                description = "A Rusty program";
                license = "gpl3Plus";
                mainprogram = "app";
              };
            };

          mkDevShell = rust-toolchain:
            pkgs.mkShell {
              LIBCLANG_PATH = "${pkgs.llvmPackages_12.libclang.lib}/lib";
              LD_LIBRARY_PATH = "${
                  pkgs.lib.makeLibraryPath buildDeps
                }:${pkgs.wayland}/lib:$LD_LIBRARY_PATH";
              packages = buildDeps ++ [ rust-toolchain ];
            };
        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };

          formatter = pkgs.alejandra;

          packages.default = self'.packages.app;
          packages.app = mkPackage "app";

          devShells.default = self'.devShells.msrv;
          devShells.msrv = mkDevShell rust-toolchain;
          devShells.stable = mkDevShell pkgs.rust-bin.stable.latest.default;
          devShells.nightly = mkDevShell (pkgs.rust-bin.selectLatestNightlyWith
            (toolchain: toolchain.default));
        };
    };
}
