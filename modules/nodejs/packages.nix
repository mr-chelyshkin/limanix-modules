{ version, system }:
let
  releases = import ./releases.nix;
  release = releases.versions.${version};
  source = releases.sources.${release.source};
  packages = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${source.rev}.tar.gz";
    inherit (source) sha256;
  }) { inherit system; };
  nodejs = packages.${release.package};
in
assert nodejs.version == release.version;
{
  inherit nodejs;
  inherit (release) endOfLife;
}
