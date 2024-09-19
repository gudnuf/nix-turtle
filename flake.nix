{
  description = "NixOS configuration for turtle with node2nix-generated holesail";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    holesail-flake.url = "github:gudnuf/holesail/flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      holesail-flake,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    #      holesail = (import ./packages/holesail {
    #       inherit pkgs system;
    #      nodejs = pkgs.nodejs_22;
    #   }).package;
    {
      nixosConfigurations = {
        turtle = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix

            # Use holesail package from the Holesail flake
            {
              environment.systemPackages = with pkgs; [
                holesail-flake.packages.${system}.holesail
              ];
            }
          ];
        };
      };
    };

}
