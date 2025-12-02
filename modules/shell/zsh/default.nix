{ lib, config, pkgs, ... }:
let
  cfg = config.modules.zsh;
  zgen-zsh = ./zgen.zsh;
  zsh-autoload = ./autoload;
in
{
  options.modules.zsh.enable = lib.mkOption { type = lib.types.bool; default = true; };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      oh-my-posh
      bat
      eza
      fasd
      fzf
    ];

    environment.shellAliases = import ./aliases.nix { inherit lib pkgs; };
    environment.variables = import ./variables.nix { };

    programs.zsh = {
      enable = true;
      enableCompletion = false;
      enableBashCompletion = false;
      promptInit = "";

      loginShellInit = ''
        if [[ $OSTYPE == darwin* ]]; then
          if [[ $CPUTYPE == arm64 ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          else
            eval "$(/usr/local/bin/brew shellenv)"
          fi
        fi
      '';

      shellInit = ''
        function match() { command grep $@ }
        function ll()  { eza -abgHhl@ --git --color=always --group-directories-first $@ | bat --paging=always --style=changes --color=always --theme="Solarized (dark)" }
        function lln() { eza -abgHhl@ --git --color=always --group-directories-first $@ | bat --paging=always --style=changes --color=always --theme="Solarized (dark)" -n }
        function lszip() { unzip -l $@ 2>&1 | sed -e "1,3d" -e "s/^.*:.. *//g" | head --lines=-2 }
        function rwhich() { realpath $(which $@) }
        function cdf() { cd $(rwhich $@ | sed "s/$@$//") }
        function sfu() { lsunits | rg -i $@ }
        function map() { for f in "$\{@:2\}"; do; eval $1 \"$f\"; done }
        ${lib.optionalString pkgs.stdenv.isDarwin "function mtr() { sudo mtr $@ }"}
      '';

      interactiveShellInit = ''
        # Turn on when measuring plugin performance
        # zmodload zsh/zprof

        HISTSIZE=10000
        SAVEHIST=10000

        bindkey -e

        setopt autocd # auto cd when only path is entered
        setopt nomatch # throw an error on glob matching nothing

        fpath=($fpath "${zsh-autoload}")
        autoload -Uz fasd_cd

        if [ -f "${zgen-zsh}" ]; then
          source "${zgen-zsh}" # ~25ms
        fi

        if [ -n "$(command -v zgen)" ]; then
          if ! zgen saved; then # TODO: auto invalidate on build
            echo "========== Creating a zgen save =========="

            # plugins
            zgen load mafredri/zsh-async
            zgen load zsh-users/zsh-autosuggestions # <10ms
            zgen load zsh-users/zsh-history-substring-search # ~5ms
            zgen load zsh-users/zsh-syntax-highlighting

            zgen load junegunn/fzf shell v0.58.0 # ~2ms
            zgen load zsh-users/zsh-completions
            # zgen load romkatv/powerlevel10k powerlevel10k

            # save all to init script
            zgen save
          fi
        fi

        # fasd: add zsh hook (same as eval "$(fasd --init zsh-hook)")
        _fasd_preexec() {
          { eval "fasd --proc $(fasd --sanitize $2)"; } >> "/dev/null" 2>&1
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook preexec _fasd_preexec

        # _direnv_hook() {
        #   eval "$(direnv export zsh 2> >( egrep -v -e '^direnv: (loading|export|unloading)' ))"
        # };

        eval "$(oh-my-posh init zsh --config ${./zen.toml})"

        echo "Greetings, Professor Falken. Shall we play a game?"
      '';
    };
  };
}
