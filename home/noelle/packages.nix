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
    blueman
    brightnessctl
    hyprsunset
    networkmanagerapplet
    pavucontrol
    playerctl
    pulseaudio
    python3
    wdisplays

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
