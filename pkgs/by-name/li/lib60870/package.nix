{
  cmake,
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lib60870";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "mz-automation";
    repo = "lib60870";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9o+gWQbpCJb+UZzPNmzGqpWD0QbGjg41is/f1POUEQs=";
  };

  separateDebugInfo = true;

  nativeBuildInputs = [ cmake ];

  preConfigure = "cd lib60870-C";

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = with lib; {
    description = "Implementation of the IEC 60870-5-101/104 protocol";
    homepage = "https://libiec61850.com/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ stv0g ];
    platforms = [ "x86_64-linux" ];
  };
})
