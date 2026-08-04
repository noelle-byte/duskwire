{ lib, pkgs, ... }:

let
  noelleTwilightCursor =
    pkgs.callPackage ../../packages/noelle-twilight-cursor.nix { };
in

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  home.pointerCursor = {
  enable = true;

  package = noelleTwilightCursor;
  name = "noelle-twilight-hyprcursor";
  size = 24;

  dotIcons.enable = true;
  gtk.enable = true;
  x11.enable = true;
  hyprcursor.enable = true;
};

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    document-font-name = "Noto Sans 11";
    monospace-font-name = "CaskaydiaCove Nerd Font 11";
    accent-color = "purple";
  };
}
