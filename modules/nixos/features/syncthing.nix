{ host, ... }:

{
  services.syncthing = {
    enable = true;
    user = host.username;
    dataDir = "/home/${host.username}";
    configDir = "/home/${host.username}/.config/syncthing";
    openDefaultPorts = true;
  };
}
