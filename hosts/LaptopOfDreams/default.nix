{ lib, host, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/core/audio.nix
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/fonts.nix
    ../../modules/nixos/core/locale.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/packages.nix
    ../../modules/nixos/core/users.nix

    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/desktop/sddm.nix

    ../../modules/nixos/duskwire-cli.nix
  ]
  ++ lib.optionals host.features.bluetooth [
    ../../modules/nixos/features/bluetooth.nix
  ]
  ++ lib.optionals host.features.development [
    ../../modules/nixos/features/development.nix
  ]
  ++ lib.optionals host.features.flatpak [
    ../../modules/nixos/features/flatpak.nix
  ]
  ++ lib.optionals host.features.gaming [
    ../../modules/nixos/features/gaming.nix
  ]
  ++ lib.optionals host.features.maintenance [
    ../../modules/nixos/features/maintenance.nix
  ]
  ++ lib.optionals host.features.printing [
    ../../modules/nixos/features/printing.nix
  ]
  ++ lib.optionals host.features.ssh [
    ../../modules/nixos/features/ssh.nix
  ]
  ++ lib.optionals host.features.syncthing [
    ../../modules/nixos/features/syncthing.nix
  ]
  ++ lib.optionals host.features.virtualisation [
    ../../modules/nixos/features/virtualisation.nix
  ];

  networking.hostName = host.hostname;
  system.stateVersion = host.systemStateVersion;
}
