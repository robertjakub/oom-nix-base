{ lib, pkgs, ... }:
{
  cat = ''${lib.getExe pkgs.bat} --paging=never --theme="Solarized (dark)"'';
  less = ''${lib.getExe pkgs.bat} --paging=always --style=changes --color=always --theme="Solarized (dark)"'';
  ls = "${lib.getExe pkgs.eza}";
  l = ''${lib.getExe pkgs.eza} -abgHhl@ --git --color=always --group-directories-first'';
  tree = "${lib.getExe pkgs.eza} --tree --color=always";
  mc = "command ${lib.getExe pkgs.mc} -u";

  # fasd
  a = "fasd -a"; # any
  s = "fasd -si"; # show / search / select
  d = "fasd -d"; # directory
  f = "fasd -f"; # file
  sd = "fasd -sid"; # interactive directory selection
  sf = "fasd -sif"; # interactive file selection
  z = "fasd_cd -d"; # cd, same functionality as j in autojump
  zz = "fasd_cd -d -i"; # cd with interactive selection
  v = "f -e nvim";
  j = "z";
}
