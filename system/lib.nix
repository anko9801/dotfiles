# Shared utility functions for the dotfiles
{ lib }:

{
  # Auto-import all .nix files and directories with default.nix from a directory
  # Usage: imports = scanPaths ./modules;
  scanPaths =
    dir:
    lib.mapAttrsToList (name: _: dir + "/${name}") (
      lib.filterAttrs (
        name: type:
        (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
        || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
      ) (builtins.readDir dir)
    );
}
