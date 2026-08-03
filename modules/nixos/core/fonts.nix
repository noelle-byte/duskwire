{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    noto-fonts
    noto-fonts-color-emoji
  ];
}
