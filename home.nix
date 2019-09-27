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
  };

  programs.command-not-found.enable = true;

  # Automounter for removable media
  services.udiskie = {
    enable = true;
  };

}
