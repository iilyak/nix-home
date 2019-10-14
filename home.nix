{ config, pkgs, ... }:

with import <nixpkgs> {};
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };
{
  imports = [
    ./modules
  ];

  home.packages = with pkgs; [
    alacritty
    chromium
    gnupg
    pinentry
    i3status-rust
    jq
    libreoffice
    nix-prefetch-git
    pass
    rofi
    unstable.starship
    swayidle
    swaylock
    udisks
    unzip
    vscodium
    wget
    wl-clipboard
    wpa_supplicant_gui
    zathura
  ];

  programs.home-manager.enable = true;

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "ILYA Khlopotov";
    userEmail = "iilyak@apache.org";

    aliases = {
        b = "branch --color -v";
        save = "!git stash save --include-untracked --keep-index \"checkpoint-`date +%Y-%m-%d.%H:%M:%S`\" && git stash apply stash@{0}";
        tree = "log --graph --decorate --oneline";
        review = "!sh -c \"git log --oneline $1.. | cut -d' ' -f1 | tail -r | xargs git show\"";
        rmmerged = "!sh -c \"git branch --merged | grep -v '^* master$' | grep -v '^  master$' | xargs git branch -d\"";
        update = "!current_branch=`git rev-parse --abbrev-ref HEAD` && git checkout master && git pull --rebase origin master && git checkout $current_branch && git rebase master";
        pr = "!git fetch origin pull/$1/head:github/pr/$1 #";
        ci = "!current_branch=`git rev-parse --abbrev-ref HEAD` && git commit --amend --no-edit && git push -f $1 $current_branch #";
    };

    extraConfig = {
        core = {
            editor = "${pkgs.micro}/bin/micro";
            excludesfile = "~/.git/.gitignore";
        };
        color = {
            ui = "auto";
        };
        pull = {
            rebase = true;
        };
    };
  };

  programs.command-not-found.enable = true;

  # Automounter for removable media
  services.udiskie = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    defaultCacheTtl = 1800;
  };

  home.file = {
    ".config/sway/config".source = ./apps/sway/config;
    ".config/sway/bindings.conf".source = ./apps/sway/bindings.conf;
    ".config/i3status-rs/config.toml".source = ./apps/i3status-rs/config.toml;
    ".config/alacritty/alacritty.yml".source = ./apps/alacritty/alacritty.yml;
    ".bashrc".source = ./apps/bash/.bashrc;
  };

  home.activation.copySecureFSJSON = dagEntryAfter ["writeBounady"] ''
      $DRY_RUN_CMD [ -f ~/.config/private/vault/.securefs.json ] || gpg --decrypt --output ~/.config/private/vault/.securefs.json ${./private/securefs.json.gpg}
      $DRY_RUN_CMD chmod 600 ~/.config/private/vault/.securefs.json
  '';

}
