{
  lib,
  stdenv,
  fetchYarnDeps,
  fixup-yarn-lock,
  fetchFromGitHub,
  yarn,
  fish,
  nodejs,
}: let
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "ndonfris";
    repo = "fish-lsp";
    rev = version;
    hash = "sha256-o5WomHED/JaamHkEOHdRJHBkfbrfJ4NbvnD/1q1yYSs=";
  };

  yarnDeps = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-hmaLWO1Sj+2VujrGD2A+COfVE2D+tCnxyojjq1512K4=";
  };
in
  stdenv.mkDerivation
  {
    pname = "fish-lsp";

    inherit version src;

    nativeBuildInputs = [
      fish
      yarn
      nodejs
      fixup-yarn-lock
    ];

    buildInputs = [
      fish
      nodejs
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      # Yarn writes temporary files to $HOME. Copied from mkYarnModules.
      export HOME=$NIX_BUILD_TOP/yarn_home

      # Make yarn install packages from our offline cache, not the registry
      yarn config --offline set yarn-offline-mirror ${yarnDeps}

      # Fixup "resolved"-entries in yarn.lock to match our offline cache
      fixup-yarn-lock yarn.lock

      yarn install --offline --frozen-lockfile --ignore-scripts --no-progress --non-interactive

      patchShebangs node_modules/

      substitute ${src}/package.json ./package.json \
        --replace-fail "yarn" "yarn --offline"

      yarn --ignore-scripts --offline run sh:build-wasm
      yarn --ignore-scripts --offline run compile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstal

      cp -r . "$out"

      runHook postInstall
    '';

    meta = {
      description = "LSP implementation for the fish shell langauge 🐠";
      homepage = "https://github.com/ndonfris/fish-lsp";
      license = lib.licenses.mit;
      mainProgram = "fish-lsp";
      maintainers = with lib.maintainers; [gungun974];
    };
  }
