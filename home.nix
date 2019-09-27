{ config, pkgs, ... }:

{
  imports = [
    ./modules
  ];
  home.packages = with pkgs; [
    alacritty
    chromium
    jq
    nix-prefetch-git
    udisks
    unzip
    wget
    wpa_supplicant_gui
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

}
