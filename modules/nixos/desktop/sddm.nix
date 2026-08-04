{ lib, pkgs, ... }:

let
  colors = import ../../../theme/colors.nix { inherit lib; };

  noelleTwilightCursor =
    pkgs.callPackage ../../../packages/noelle-twilight-cursor.nix { };

  hex = name:
    "#${builtins.substring 0 6 colors.${name}}";

  themeConfig = pkgs.writeText "theme.conf" ''
    [General]

    Background=background.webp

    Night=${hex "night"}
    Indigo=${hex "indigo"}
    Periwinkle=${hex "periwinkle"}
    Lavender=${hex "lavender"}
    Violet=${hex "violet"}
    Orchid=${hex "orchid"}
    Pink=${hex "pink"}
    Amber=${hex "amber"}
    Cream=${hex "cream"}
    Text=${hex "text"}
    Muted=${hex "muted"}
    Shadow=${hex "shadow"}
  '';

  duskwireTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "duskwire-twilight-sddm";
    version = "1.0";

    dontUnpack = true;

    installPhase = ''
      themeDir="$out/share/sddm/themes/duskwire-twilight"
      mkdir -p "$themeDir"

      cp ${../../../theme/sddm/Main.qml} "$themeDir/Main.qml"
      cp ${../../../theme/sddm/metadata.desktop} "$themeDir/metadata.desktop"
      cp ${../../../assets/login-wallpaper.webp} "$themeDir/background.webp"
      cp ${themeConfig} "$themeDir/theme.conf"
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "duskwire-twilight";
    extraPackages = [ duskwireTheme ];
    settings.Theme.CursorTheme = "noelle-twilight-hyprcursor";
  };

  environment.systemPackages = [
    duskwireTheme
    noelleTwilightCursor
  ];
}
