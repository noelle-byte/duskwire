{
  stdenvNoCC,
  python3,
  librsvg,
  xorg,
}:

stdenvNoCC.mkDerivation {
  pname = "noelle-twilight-cursor";
  version = "1.2";

  src = ../assets/cursors/noelle-twilight-hyprcursor;

  nativeBuildInputs = [
    python3
    librsvg
    xorg.xcursorgen
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    theme="$out/share/icons/noelle-twilight-hyprcursor"
    mkdir -p "$theme"
    cp -a . "$theme/"

    python3 ${./build-noelle-twilight-xcursor.py} \
      --source "$theme/hyprcursors_uncompressed" \
      --output "$theme" \
      --sizes 24,32,48,64,96

    test -f "$theme/manifest.hl"
    test -d "$theme/hyprcursors"
    test -f "$theme/index.theme"
    test -d "$theme/cursors"
    test -e "$theme/cursors/default"
    test -e "$theme/cursors/left_ptr"

    runHook postInstall
  '';
}
