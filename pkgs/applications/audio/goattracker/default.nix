{
  lib,
  stdenv,
  fetchurl,
  unzip,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
  SDL,
  isStereo ? false,
}:

let
  pname = "goattracker" + lib.optionalString isStereo "-stereo";
  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "GoatTracker 2" + lib.optionalString isStereo " Stereo";
    genericName = "Music Tracker";
    exec = if isStereo then "gt2stereo" else "goattrk2";
    icon = "goattracker";
    categories = [
      "AudioVideo"
      "AudioVideoEditing"
    ];
    keywords = [
      "tracker"
      "music"
    ];
  };

in
stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  version =
    if isStereo then
      "2.77" # stereo
    else
      "2.77"; # normal

  src = fetchurl {
    url = "mirror://sourceforge/goattracker2/GoatTracker_${finalAttrs.version}${lib.optionalString isStereo "_Stereo"}.zip";
    sha256 =
      if isStereo then
        "1hiig2d152sv9kazwz33i56x1c54h5sh21ipkqnp6qlnwj8x1ksy" # stereo
      else
        "sha256-lsK9amqzrKL1uxixx2SsbqaawkXK4UACpyzYfFVFYe8="; # normal
  };
  sourceRoot = "src";

  nativeBuildInputs = [
    copyDesktopItems
    unzip
    imagemagick
  ];
  buildInputs = [ SDL ];

  # PREFIX gets treated as BINDIR.
  makeFlags = [ "PREFIX=$(out)/bin/" ];

  # The zip contains some build artifacts.
  prePatch = ''
    make clean
  '';

  # The destination does not get created automatically.
  preBuild = ''
    mkdir -p $out/bin
  '';

  # Other files get installed during the build phase.
  installPhase = ''
    runHook preInstall

    convert goattrk2.bmp goattracker.png
    install -Dm644 goattracker.png $out/share/icons/hicolor/32x32/apps/goattracker.png
    ${lib.optionalString (
      !isStereo
    ) "install -Dm644 ../linux/goattracker.1 $out/share/man/man1/goattracker.1"}

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description =
      "Crossplatform music editor for creating Commodore 64 music. Uses reSID library by Dag Lem and supports alternatively HardSID & CatWeasel devices"
      + lib.optionalString isStereo " - Stereo version";
    homepage = "https://cadaver.github.io/tools.html";
    downloadPage = "https://sourceforge.net/projects/goattracker2/";
    license = lib.licenses.gpl2Plus;
    mainProgram = if isStereo then "gt2stereo" else "goattrk2";
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
  };
})
