{
  description = "NixOS configuration for turtle";

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
