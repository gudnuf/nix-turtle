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

  fileSystems."/mnt/nvme" = {
    device = "/dev/nvme0n1p1";
    fsType = "ext4";
  };

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
    dataDir = "/mnt/nvme/bitcoind";
  };

  services.clightning = {
    enable = true;
    address = "0.0.0.0";
    package = pkgs.clightning;

    extraConfig = ''
      #  log-level=debug
    '';
    plugins = {
      clboss = {
        enable = true;
        min-onchain = 80000;
        min-channel = 1700000;
        zerobasefee = "disallow";
  #      package = pkgs.clboss;
      };
    };
  };

  services.fulcrum = {
    enable = true;
  };

  services.mempool = {
    enable = true;
    electrumServer = "fulcrum";
    # port = 60845;
  };

  nix-bitcoin.nodeinfo.enable = true;

  services.vaultwarden = {
    enable = true;
    config = {

      #DOMAIN = "https://${}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8777;
      ROCKET_LOG = "critical";
    };
    dbBackend = "sqlite";
    environmentFile = "/var/lib/secrets/vaultwarden/vaultwarden.env";
  };
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
