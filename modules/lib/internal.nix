{ lib, ... }:
let
  inherit (lib) lists filter hasSuffix flatten;
  inherit (lib) optionalString replaceStrings filterAttrs;
  inherit (lib) tail head hasAttrByPath getAttrFromPath;
  inherit (lib) warn strings isAttrs;
  inherit (builtins) attrNames readDir getEnv tryEval;
in
rec {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../../.;
  relativeToDefaults = lib.path.append ../../defaults/.;

  scanPaths = path: (map
    (f: (path + "/${f}"))
    (attrNames (
      filterAttrs
        (path: _type: (_type == "regular") && ((path != "default.nix") && (hasSuffix ".nix" path)))
        (readDir path)
    )));

  cwd = getEnv "PWD";

  ifelse = a: b: c:
    if a
    then b
    else c;

  lst =
    { p ? cwd
    , t ? "regular"
    , b ? false
    ,
    }: (lists.forEach
      (attrNames
        (filterAttrs (n: v: v == t)
          (readDir p)))
      (v: ((optionalString b "${p}/") + v)));

  lsf = p: (lst { inherit p; });

  lsd = p: (lst {
    inherit p;
    t = "directory";
    b = true;
  });

  lsfRec = p: b:
    flatten ((map (np: lsfRec np b) (lsd p))
      ++ (lst {
      inherit p;
      inherit b;
    }));

  makeOptionTypeList = path: (
    lists.forEach
      # get a list of all files ending in .nix in path
      (filter (hasSuffix ".nix") (lsfRec path true))
      # remove leading path and trailing ".nix", replace every slash with "::"
      (replaceStrings [ "${path}/" "/" ".nix" ] [ "" "::" "" ])
  );

  makeOptionSuffixList =
    { p ? cwd
    , s ? ".nix"
    ,
    }: (
      lists.forEach
        (filter (hasSuffix s) (lsfRec p true))
        (replaceStrings [ "${p}/" "/" s ] [ "" "::" "" ])
    );

  meetsConDo = cond: do: l:
    ifelse (l == [ ]) false
      (
        let
          h = head l;
          t = tail l;
        in
        ifelse (cond h) (do h)
          (meetsConDo cond do t)
      );

  deps = p:
    ifelse (isAttrs p)
      (
        filter isAttrs
          (p.buildInputs ++ p.nativeBuildInputs ++ p.propagatedBuildInputs ++ p.propagatedNativeBuildInputs)
      ) [ ];

  isBroken = p:
    meetsConDo (s: ((hasAttrByPath s.path p) && (s.check (getAttrFromPath s.path p)))) (s: s.msg)
      [
        {
          path = [ "meta" "broken" ];
          msg = warn "Package ${p.name} is marked as broken." true;
          check = m: m;
        }
        {
          path = [ "meta" "knownVulnerabilities" ];
          msg = warn "Package ${p.name} has known Vulnerabilities.." true;
          check = m: m != [ ];
        }
        {
          path = [ "name" ];
          msg = warn "${p.name}: python2 is depricated." false;
          check = m: (strings.hasInfix "python2" m) || (strings.hasInfix "python-2" m);
        }
        # not sure if the following test creates false positives (AFAIK every derivation/package needs to have an outPath)
        # , definitely should catch all corner cases/everything that fails to evaluate.
        {
          path = [ "outPath" ];
          msg = warn "Package ${p.name} has no outPath" true;
          check = m: !(tryEval m).success;
        }
      ];

  depsBroken = p: lists.any (p: (isBroken p)) (deps p);

  depsBrokenRec = p: (
    meetsConDo
      (p: ifelse (depsBroken p) true (depsBrokenRec (deps p)))
      (p: true)
      (deps p)
  );

  pkgFilter = ld: (filter
    (p: (
      ifelse (isBroken p)
        false
        (ifelse (depsBrokenRec p)
          (warn "Dependency of ${p.name} is marked as broken." false)
          true)
    ))
    ld);
}
