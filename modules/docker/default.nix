{ runtime, ... }:
{
  virtualisation.docker.enable = true;
  users.users.${runtime.user.name}.extraGroups = [ "docker" ];
}
