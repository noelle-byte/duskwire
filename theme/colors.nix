{ lib }:

let
  lines =
    lib.splitString "\n"
      (builtins.readFile ./colors.conf);

  usefulLines =
    builtins.filter
      (line: line != "" && !(lib.hasPrefix "#" line))
      lines;

  parseLine = line:
    let
      result =
        builtins.match
          "([A-Za-z][A-Za-z0-9_-]*)=([0-9A-Fa-f]{8})"
          line;
    in
      if result == null then
        throw "Invalid colour entry in colors.conf: ${line}"
      else
        {
          name = builtins.elemAt result 0;
          value = builtins.elemAt result 1;
        };
in
builtins.listToAttrs (builtins.map parseLine usefulLines)
