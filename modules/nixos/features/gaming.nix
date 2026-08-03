{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gamescope
    mangohud
  ];
}
