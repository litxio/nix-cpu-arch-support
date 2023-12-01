{
  description = "Small library for flakes with derivations per CPU architecture";

  inputs = {
    cpu-architectures.url = "path:./cpu-architectures";
  };

  outputs = { self, cpu-architectures}: {
    lib = 
      let genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
          nameValuePair = name: value: { inherit name value; };
          cpus = cpu-architectures.cpu-architectures;
          eachCpuFlattened = tree:
            let
              op = sum: path: val:
                let
                  pathStr = builtins.concatStringsSep "/" path;
                in
                  if (builtins.typeOf val) == "lambda" then
                    # ignore that value
                    # builtins.trace "${pathStr} is not of type set"
                    sum // (builtins.listToAttrs (map (cpu: nameValuePair "${pathStr}/${cpu}" (val cpu))
                                                      cpus))
                  else if (builtins.typeOf val) == "set" then
                    # builtins.trace "${pathStr} is a recursive"
                    # recurse into that attribute set
                    (recurse sum path val)
                  else #  if val ? type && val.type == "derivation" then
                    # builtins.trace "${pathStr} is a derivation"
                    # we used to use the derivation outPath as the key, but that crashes Nix
                    # so fallback on constructing a static key
                    (sum // {
                      "${pathStr}" = val;
                    })
              ;

              recurse = sum: path: val:
                builtins.foldl'
                  (sum: key: op sum (path ++ [ key ]) val.${key})
                  sum
                  (builtins.attrNames val)
              ;
            in recurse { } [ ] tree;
      in {
        eachCpu = f: genAttrs cpu-architectures.cpu-architectures f;
        # Takes a nested attrset where each leaf node is a function taking an architecture
        inherit eachCpuFlattened;
      };
  };
}

