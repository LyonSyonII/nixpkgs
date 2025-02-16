{ lib
, stdenv
, fetchFromGitHub
, php
, pkgs
, nixosTests
, dataDir ? "/var/lib/pixelfed"
, runtimeDir ? "/run/pixelfed"
}:

let
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true; # Disable development dependencies
  }).overrideAttrs (attrs : {
    installPhase = attrs.installPhase + ''
      rm -R $out/bootstrap/cache
      # Move static contents for the NixOS module to pick it up, if needed.
      mv $out/bootstrap $out/bootstrap-static
      mv $out/storage $out/storage-static
      ln -s ${dataDir}/.env $out/.env
      ln -s ${dataDir}/storage $out/
      ln -s ${dataDir}/storage/app/public $out/public/storage
      ln -s ${runtimeDir} $out/bootstrap
      chmod +x $out/artisan
    '';
  });
in package.override rec {
  pname = "pixelfed";
  version = "0.11.5";

  # GitHub distribution does not include vendored files
  src = fetchFromGitHub {
    owner = "pixelfed";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ZrvYKMSx5WymWR46/UKr5jCsclXXzBeY21ju22zeqN0=";
  };

  passthru.tests = { inherit (nixosTests) pixelfed; };

  meta = with lib; {
    description = "A federated image sharing platform";
    license = licenses.agpl3Only;
    homepage = "https://pixelfed.org/";
    maintainers = with maintainers; [ raitobezarius ];
    platforms = php.meta.platforms;
  };
}
