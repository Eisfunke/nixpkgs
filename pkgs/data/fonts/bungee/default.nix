{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "bungee";
  version = "1.2.0";

  src = fetchzip {
    url = "https://github.com/djrrb/Bungee/releases/download/v1.2.0/Bungee-fonts.zip";
    hash = "sha256-lol";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 camingo-code/*.ttf -t $out/share/fonts/truetype
    install -Dm644 camingo-code/*.txt -t $out/share/doc/${pname}-${version}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://djr.com/bungee";
    description = "TODO";
    platforms = platforms.all;
    license = licenses.ofl;
  };
}
