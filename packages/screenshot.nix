{ pkgs }:

pkgs.writeShellApplication {
  name = "duskwire-screenshot";

  runtimeInputs = with pkgs; [
    coreutils
    grim
    libnotify
    slurp
    wl-clipboard
  ];

  text = ''
    set -euo pipefail

    mode="''${1:-area}"
    directory="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
    filename="$directory/$(date +'%Y-%m-%d_%H-%M-%S').png"

    mkdir -p "$directory"

    case "$mode" in
      area)
        geometry="$(slurp)" || exit 0
        grim -g "$geometry" "$filename"
        ;;
      full)
        grim "$filename"
        ;;
      *)
        echo "Usage: duskwire-screenshot [area|full]" >&2
        exit 2
        ;;
    esac

    wl-copy < "$filename"
    notify-send "Screenshot captured" "$filename"
  '';
}
