{
  description = "NixOS configuration for turtle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    holesail.url = "github:gudnuf/holesail-nix";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    nixpkgs.follows = "nix-bitcoin/nixpkgs";
    nixpkgs-unstable.follows = "nix-bitcoin/nixpkgs-unstable";
    clboss.url = "github:ZmnSCPxj/clboss/master";
  };

  outputs =
    {
      self,
      nixpkgs,
      holesail,
      home-manager,
      nix-bitcoin,
      clboss,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        turtle = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            nix-bitcoin.nixosModules.default

            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [ (final: prev: { clboss = clboss.packages.${pkgs.system}.default; }) ];
              }
            )

            ./configuration.nix

            { environment.systemPackages = [ holesail.packages.x86_64-linux.default ]; }
          ];

        };
      };

      homeConfigurations = {
        gudnuf = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };
    };
}
