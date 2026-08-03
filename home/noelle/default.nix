{ host, ... }:

{
  imports = [
    ./dotfiles.nix
    ./packages.nix
    ./programs.nix
    ./theme.nix
  ];

  home = {
    username = host.username;
    homeDirectory = "/home/${host.username}";
    stateVersion = host.homeStateVersion;
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
