{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gh
    nil
    nix-output-monitor
  ];
}
