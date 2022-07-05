{ lib }:
lib.makeExtensible (self: {
  filterEnabled = filterAttrs (_: conf: conf.enable);
})
