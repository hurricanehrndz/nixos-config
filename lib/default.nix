{ lib }:
lib.makeExtensible (self: {
  filterEnabled = lib.attrsets.filterAttrs (_: conf: conf.enable);
})
