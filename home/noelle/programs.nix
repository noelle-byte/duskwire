{ lib, pkgs, host, ... }:

let
  colors = import ../../theme/colors.nix { inherit lib; };

  hex = name:
    "#${builtins.substring 0 6 colors.${name}}";

  starshipBase = builtins.fromTOML (
    builtins.readFile ../../theme/starship.toml
  );
in
{
  programs.git.enable = true;

  programs.fish = {
    enable = true;

    interactiveShellInit = builtins.readFile ../../dotfiles/fish/config.fish;

    shellAliases = {
      dw = "duskwire switch";
      dwb = "duskwire build";
      dwt = "duskwire test";
      dwu = "duskwire update";
      dwg = "duskwire generations";
    };
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/kitty/kitty.conf;
  };

  programs.nh = {
    enable = true;
    flake = host.repoPath;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = lib.recursiveUpdate starshipBase {
      palettes.twilight = {
        night = hex "night";
        indigo = hex "indigo";
        periwinkle = hex "periwinkle";
        lavender = hex "lavender";
        violet = hex "violet";
        orchid = hex "orchid";
        pink = hex "pink";
        amber = hex "amber";
        cream = hex "cream";
        text = hex "text";
        muted = hex "muted";
      };
    };
  };
}
