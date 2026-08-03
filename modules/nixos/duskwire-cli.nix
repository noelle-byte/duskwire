{ pkgs, host, ... }:

let
  duskwire = pkgs.writeShellApplication {
    name = "duskwire";

    runtimeInputs = with pkgs; [
      git
      nh
      nix
    ];

    text = ''
      set -euo pipefail

      flake="''${DUSKWIRE_FLAKE:-${host.repoPath}}"
      target="$flake#${host.hostname}"
      command="''${1:-help}"

      if [ "$#" -gt 0 ]; then
        shift
      fi

      require_flake() {
        if [ ! -f "$flake/flake.nix" ]; then
          echo "Duskwire checkout not found at: $flake" >&2
          echo "Edit hosts/${host.hostname}/variables.nix if you moved it." >&2
          exit 1
        fi
      }

      case "$command" in
        build|check)
          require_flake
          exec nh os build "$target" "$@"
          ;;

        test)
          require_flake
          exec nh os test "$target" "$@"
          ;;

        switch|rebuild)
          require_flake
          exec nh os switch "$target" "$@"
          ;;

        update)
          require_flake
          cd "$flake"
          nix flake update
          exec nh os switch "$target" "$@"
          ;;

        generations|gens)
          exec sudo nix-env \
            --profile /nix/var/nix/profiles/system \
            --list-generations
          ;;

        rollback)
          generation="''${1:-}"

          if [ -z "$generation" ]; then
            exec sudo nixos-rebuild switch --rollback
          fi

          case "$generation" in
            *[!0-9]*)
              echo "Generation must be a number." >&2
              exit 2
              ;;
          esac

          link="/nix/var/nix/profiles/system-$generation-link"

          if [ ! -x "$link/bin/switch-to-configuration" ]; then
            echo "NixOS generation $generation does not exist." >&2
            exit 1
          fi

          exec sudo "$link/bin/switch-to-configuration" switch
          ;;

        clean)
          sudo nix-env \
            --profile /nix/var/nix/profiles/system \
            --delete-generations +5
          exec sudo nix-store --gc
          ;;

        path)
          printf '%s\n' "$flake"
          ;;

        help|-h|--help)
          cat <<'HELP'
      Duskwire system manager

      Usage: duskwire <command>

        build          Build without activating
        test           Activate until the next reboot
        switch         Build and activate permanently
        update         Update flake.lock, then switch
        generations    List NixOS generations
        rollback [N]   Return to the previous or selected generation
        clean          Keep five generations and collect garbage
        path           Print the configured checkout path
      HELP
          ;;

        *)
          echo "Unknown Duskwire command: $command" >&2
          echo "Run 'duskwire help' for available commands." >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [ duskwire ];

  environment.sessionVariables.DUSKWIRE_FLAKE = host.repoPath;
}
