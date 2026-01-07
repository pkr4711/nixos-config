{
  description = "Nixos setup pkr4711";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # This should correspond to the hostname of the machine
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
  };
}
