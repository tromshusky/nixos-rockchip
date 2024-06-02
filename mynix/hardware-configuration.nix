{ config, lib, pkgs, modulesPath, ... }:

{
  imports = 
    [  (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };
  
  swapDevices = [ ];
  networking.useDHCP = lin.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
