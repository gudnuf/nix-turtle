{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "turtle";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angelas";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  users.users.gudnuf = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "bitcoin"
      "clightning"
    ];
    packages = with pkgs; [
      tree
      git
      neovim
    ];
    initialPassword = "password";
  };

  environment.systemPackages = [ pkgs.neovim ];

  # stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  nix-bitcoin.operator = {
    enable = true;
    name = "gudnuf";
  };

  #turn on tor for CLN
  nix-bitcoin.onionServices.clightning = {
    enable = true;
    public = true;
  };

  services.bitcoind = {
    enable = true;
    txindex = true;
    address = "0.0.0.0";
    listen = true;
  };

  services.clightning = {
    enable = true;
    address = "0.0.0.0";

    extraConfig = ''
      experimental-offers
      experimental-dual-fund
      experimental-splicing
    '';
    plugins = {
      clboss = {
        enable = true;
        min-onchain = 80000;
        min-channel = 1700000;
      };
    };
  };

  services.fulcrum = {
    enable = true;
  };

  services.mempool = {
    enable = true;
    electrumServer = "fulcrum";
  };

  nix-bitcoin.nodeinfo.enable = true;

  # services.vaultwarden.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8333
      9735
    ];
  };

  # was getting an error that this failed to start
  systemd.services.NetworkManager-wait-online.enable = false;

  # enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
