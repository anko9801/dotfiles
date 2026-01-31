{ lib, ... }:

rec {
  # Wrap unfree packages with warnings
  # Usage: setUnfreeWarning { maybeAttrs = unfreePkgs; prefix = "pkgs"; }
  setUnfreeWarning =
    {
      maybeAttrs,
      prefix,
    }:
    let
      withoutWarning =
        if builtins.isAttrs maybeAttrs then
          builtins.mapAttrs (
            name: value:
            setUnfreeWarning {
              maybeAttrs = value;
              prefix = "${prefix}.${name}";
            }
          ) maybeAttrs
        else
          maybeAttrs;
      withWarning =
        if lib.isDerivation withoutWarning then
          builtins.warn "Using UNFREE package: ${prefix}" withoutWarning
        else
          withoutWarning;
    in
    withWarning;
}
