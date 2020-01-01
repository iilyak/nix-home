{ config, pkgs, ... }:

with import <nixpkgs> {};
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };
let
nigthlyRustChannel = pkgs.rustChannelOf { date = "2019-12-27"; channel = "nightly"; };
nightlyRustPlatform = makeRustPlatform {
    rustc = nigthlyRustChannel.rust;
    cargo = nigthlyRustChannel.cargo;
  };

pi = nightlyRustPlatform.buildRustPackage rec {
    name = "pi";
    version = "3.1.19";

    src = fetchgit {
      url = "https://github.com/vmchale/project-init";
      rev = "5fa419d254f688f15384a54ffbe12af8abd69435";
      sha256 = "1hcg015b02h1rz50fwkvx88sn008z8v21n1amh96vf5zfr4ikxrl";
    };

    depsSha256 = "";
    meta = with stdenv.lib; {
        description = "Command line program for bootstraping projects";
        homepage = "https://github.com/vmchale/project-init";
    };
    cargoSha256 = "0sprwck5w7kscyfm4lb7zibabyqcjv7lcmqwrhprq6jfk6jxlk21";

    buildInputs = [
      pkgconfig
      openssl
    ];
};

in
{
  imports = [
    ./modules
  ];

  home.packages = with pkgs; [
    alacritty
    bat # terminal file viever
    cargo
    chromium
    direnv
    firefox-wayland
    gcc
    ghc
    gimp
    go_1_12
    gnumake
    gnupg
    pinentry
    rustc
    htop
    i3status-rust
    jq
    libreoffice
    nix-prefetch-git
    nodejs-11_x
    pandoc
    pass # terminal password manager
    ripgrep # rg - fast grep
    rofi
    unstable.starship
    swayidle
    swaylock
    tree
    udisks
    unzip
    vlc
    vscodium
    wget
    wl-clipboard
    wpa_supplicant_gui
    zathura # document viewer
    zeal # offline documentation viewer
  ] ++ [
    pi
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
