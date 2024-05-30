{
  description = "Build example NixOS image for PineTab2";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    rockchip = { url = "github:nabam/nixos-rockchip"; };
  };

  # Use cache with packages from nabam/nixos-rockchip CI.
  nixConfig = {
    extra-substituters = [ "https://pinetab2th.cachix.org" ];
    extra-trusted-public-keys = [
      "pinetab2th.cachix.org-1:HfHv9nUkkyt3DlhR04CakY7yBzhQvb6CejsbAS1/44s="
    ];
  };

  outputs = { self, ... }@inputs:
    let
      osConfig = buildPlatform:
        inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.rockchip.nixosModules.sdImageRockchip
            inputs.rockchip.nixosModules.dtOverlayQuartz64ASATA
            inputs.rockchip.nixosModules.dtOverlayPCIeFix
            ./config.nix
            {
              # Use cross-compilation for uBoot and Kernel.
              rockchip.uBoot =
                inputs.rockchip.packages.${buildPlatform}.uBootPineTab2;
              boot.kernelPackages =
                inputs.rockchip.legacyPackages.${buildPlatform}.kernel_linux_6_8_pinetab;
            }

            inputs.rockchip.nixosModules.noZFS # ZFS is broken on kernel from unstable
          ];
        };
    in {
      # Set buildPlatform to "x86_64-linux" to benefit from cross-compiled packages in the cache.
      nixosConfigurations.quartz64 = osConfig "x86_64-linux";

      # Or use configuration below to compile kernel and uBoot on device.
      # nixosConfigurations.quartz64 = osConfig "aarch64-linux";
    } // inputs.utils.lib.eachDefaultSystem (system: {
      # Set buildPlatform to "x86_64-linux" to benefit from cross-compiled packages in the cache.
      packages.image = (osConfig "x86_64-linux").config.system.build.sdImage;

      # Or use configuration below to cross-compile kernel and uBoot on the current platform.
      # packages.image = (osConfig system).config.system.build.sdImage;

      packages.default = self.packages.${system}.image;
    });
}
