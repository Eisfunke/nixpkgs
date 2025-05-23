{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "atasm";
  version = "1.28";

  src = fetchFromGitHub {
    owner = "CycoPH";
    repo = "atasm";
    rev = "V${version}";
    hash = "sha256-9hDY+DQ2qA6zgVMCfvXW7QErH+eL1TKya4PpQ3vHQLQ=";
  };

  makefile = "Makefile";

  patches = [
    # make install fails because atasm.txt was moved; report to upstream
    ./0000-file-not-found.diff
    # select flags for compilation
    ./0001-select-flags.diff
  ];

  dontConfigure = true;

  buildInputs = [
    zlib
  ];

  preBuild = ''
    makeFlagsArray+=(
      -C ./src
      CC=cc
      USEZ="-DZLIB_CAPABLE -I${zlib}/include"
      ZLIB="-L${zlib}/lib -lz"
      UNIX="-DUNIX"
    )
  '';

  preInstall = ''
    mkdir -p $out/bin/
    install -d $out/share/doc/${pname} $out/man/man1
    installFlagsArray+=(
      DESTDIR=$out/bin/
      DOCDIR=$out/share/doc/${pname}
      MANDIR=$out/man/man1
    )
  '';

  postInstall = ''
    mv docs/* $out/share/doc/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/CycoPH/atasm";
    description = "Commandline 6502 assembler compatible with Mac/65";
    license = licenses.gpl2Plus;
    changelog = "https://github.com/CycoPH/atasm/releases/tag/V${version}";
    maintainers = with maintainers; [ ];
    platforms = with platforms; unix;
  };
}
