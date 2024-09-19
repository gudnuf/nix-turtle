{
  description = "NixOS configuration for turtle with holesail";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    holesail.url = "github:gudnuf/holesail-nix/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      holesail,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations = {
        turtle = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix

            # Use holesail package directly from the local Holesail flake
            {
              environment.systemPackages = [
                holesail.packages.x86_64-linux.default
	      ];
            }
          ];
        };
      };
    };
}
