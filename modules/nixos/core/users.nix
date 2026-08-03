{ pkgs, host, ... }:

{
  programs.fish.enable = true;

  users.users.${host.username} = {
    isNormalUser = true;
    description = host.username;
    home = "/home/${host.username}";
    shell = pkgs.fish;

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
