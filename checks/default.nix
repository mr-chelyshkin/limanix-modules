let
  catalog = import ./catalog.nix ../modules;
  nixpkgs = import ./nixpkgs.nix;
  systems = {
    arm64 = "aarch64-linux";
    amd64 = "x86_64-linux";
  };

  checkSystem =
    arch: system:
    let
      evaluate =
        label: selected:
        let
          configuration = import ./nixos.nix {
            inherit nixpkgs arch system;
            modules = builtins.map (module: module.path) selected;
          };
        in
        builtins.trace "Checking ${system}: ${label}" (
          builtins.addErrorContext "while checking ${label} on ${system}" configuration.config.system.build.toplevel.drvPath
        );
    in
    {
      individual = builtins.listToAttrs (
        builtins.map (module: {
          inherit (module) name;
          value = evaluate module.name [ module ];
        }) catalog
      );
      combined = evaluate "all modules" catalog;
    };
in
builtins.deepSeq catalog (builtins.mapAttrs checkSystem systems)
