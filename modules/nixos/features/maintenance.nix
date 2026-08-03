{ pkgs, ... }:

{
  systemd.services.duskwire-trim-generations = {
    description = "Keep the latest five NixOS generations";
    serviceConfig.Type = "oneshot";

    script = ''
      ${pkgs.nix}/bin/nix-env \
        --profile /nix/var/nix/profiles/system \
        --delete-generations +5

      ${pkgs.nix}/bin/nix-store --gc
    '';
  };

  systemd.timers.duskwire-trim-generations = {
    description = "Weekly Duskwire generation cleanup";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
