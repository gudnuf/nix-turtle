{
  description = "NixOS configuration for turtle";

  inputs = {
    holesail.url = "github:gudnuf/holesail-nix";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/master";
    nixpkgs.follows = "nix-bitcoin/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    clboss.url = "github:ZmnSCPxj/clboss/master";
    cln_nwc.url = "github:gudnuf/cln_nwc/v0.1.2";
  };
  outputs =
    {
      self,
      nixpkgs,
      holesail,
      # home-manager,
      nix-bitcoin,
      clboss,
      cln_nwc,
      nixpkgs-unstable,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

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
                nixpkgs.overlays = [
                  (final: prev: {
                    clboss = clboss.packages.${pkgs.system}.default;
                    cln_nwc = cln_nwc.packages.${pkgs.system}.default;
                    clightning = pkgs-unstable.clightning;
                  })
                ];
              }
            )

            ./configuration.nix

            { environment.systemPackages = [ holesail.packages.x86_64-linux.default ]; }
          ];

        };
      };

      # homeConfigurations = {
      #    gudnuf = home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #     modules = [ ./home.nix ];
      #   };
      # };
    };
}
