{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  d2n = config.dream2nix;

  # make attrs default, so that users can override them without
  # needing to use lib.mkOverride (usually, lib.mkForce)
  mkDefaultRecursive = attrs:
    l.mapAttrsRecursiveCond
    d2n.lib.dlib.isNotDrvAttrs
    (_: l.mkDefault)
    attrs;
in {
  config = {
    perSystem = {
      config,
      pkgs,
      ...
    }: let
      instance = d2n.lib.init {
        inherit pkgs;
        inherit (d2n) config;
      };

      outputs =
        l.mapAttrs
        (_: args: instance.dream2nix-interface.makeOutputs args)
        config.dream2nix.inputs;

      getAttrFromOutputs = attrName:
        l.mkMerge (
          l.mapAttrsToList
          (_: output: mkDefaultRecursive output.${attrName} or {})
          outputs
        );
    in {
      config = {
        dream2nix = {inherit instance outputs;};
      };
    };
  };
}
