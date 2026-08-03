{ host, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users.${host.username}.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
