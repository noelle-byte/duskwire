{
  description = "Duskwire — Noelle's declarative NixOS system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      host = import ./hosts/LaptopOfDreams/variables.nix;
      pkgs = nixpkgs.legacyPackages.${host.system};
    in
    {
      nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
        system = host.system;

        specialArgs = {
          inherit inputs self host;
        };

        modules = [
          ./hosts/LaptopOfDreams
          home-manager.nixosModules.home-manager

          {
            home-manager = {
              backupFileExtension = "pre-duskwire";
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit inputs self host;
              };

              users.${host.username} = import ./home/noelle;
            };
          }
        ];
      };

      devShells.${host.system}.default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          deadnix
          git
          nil
          shellcheck
          statix
        ];

        shellHook = ''
          echo "Duskwire development shell"
          echo "  alejandra .   format Nix"
          echo "  statix check ."
          echo "  deadnix ."
        '';
      };

      formatter.${host.system} = pkgs.alejandra;

      templates = {
        python = {
          path = ./templates/python;
          description = "Python project with uv, Ruff and Pyright";
        };

        rust = {
          path = ./templates/rust;
          description = "Rust project with Cargo, Clippy and rust-analyzer";
        };

        node = {
          path = ./templates/node;
          description = "Node.js project shell";
        };

        kotlin = {
          path = ./templates/kotlin;
          description = "Kotlin/JVM project with JDK 21 and Gradle";
        };

        default = self.templates.python;
      };
    };
}
