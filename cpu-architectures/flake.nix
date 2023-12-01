{
  description = "List of CPU architectures (overrideable)";

  outputs = { self, ... }: {
    cpu-architectures = [ "x86-64-v2" "x86-64-v3" "x86-64-v4" "znver2" "znver3" "znver4" ];
  };
}



