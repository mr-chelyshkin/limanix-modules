modulesDir:
let
  entries = builtins.readDir modulesDir;
  names = builtins.attrNames entries;

  require = condition: message: if condition then true else throw "Module catalog: ${message}";

  readModule =
    name:
    assert require (entries.${name} == "directory") "${name} must be a directory";
    assert require (
      builtins.stringLength name <= 63 && builtins.match "[a-z][a-z0-9]*(-[a-z0-9]+)*" name != null
    ) "invalid module name: ${name}";
    let
      directory = modulesDir + "/${name}";
      files = builtins.readDir directory;
      metadata = builtins.addErrorContext "while reading ${name}/module.toml" (
        builtins.fromTOML (builtins.readFile (directory + "/module.toml"))
      );
    in
    assert require (
      files."default.nix" or null == "regular"
    ) "${name}/default.nix must be a regular file";
    assert require (
      files."module.toml" or null == "regular"
    ) "${name}/module.toml must be a regular file";
    assert require (
      builtins.attrNames metadata == [ "description" ]
    ) "${name}/module.toml must contain only description";
    assert require (builtins.isString metadata.description) "${name}: description must be a string";
    assert require (
      builtins.match "[[:space:]]*" metadata.description == null
    ) "${name}: description must not be empty";
    {
      inherit name;
      inherit (metadata) description;
      path = directory + "/default.nix";
    };
in
assert require (names != [ ]) "no modules found";
builtins.map readModule names
