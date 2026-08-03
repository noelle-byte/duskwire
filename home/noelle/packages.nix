{ pkgs, ... }:

let
  screenshot = import ../../packages/screenshot.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # Desktop shell
    eww
    hyprcursor
    hyprpaper
    thunar
    waybar
    wofi

    # Desktop controls
    brightnessctl
    pavucontrol
    playerctl

    # Wayland utilities
    grim
    libnotify
    slurp
    wl-clipboard

    # Terminal and development
    gh
    vscodium

    # System utilities
    btop
    fastfetch
    hyfetch

    # Creative applications
    gimp
    inkscape

    screenshot
  ];
}
