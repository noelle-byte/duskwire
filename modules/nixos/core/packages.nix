{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    glib
    hyprpolkitagent
    rsync
    xdg-utils
  ];
}
