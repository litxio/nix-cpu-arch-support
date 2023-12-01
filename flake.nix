{
  description = "Small library for flakes with derivations per CPU architecture";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    cpu-architectures.url = "path:./cpu-architectures";
  };

  outputs = { self, flake-utils, cpu-architectures}: {
    lib = 
      let genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
          nameValuePair = name: value: { inherit name value; };
      in rec {
        eachCpu = f: genAttrs cpu-architectures.cpu-architectures f;
        eachCpuFlat = f: flake-utils.lib.flattenTree (eachCpu f // { recurseForDerivations = true; });
      };
  };
}

