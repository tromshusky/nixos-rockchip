{ config, lib, pkgs, ...}:

{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxKernel.kernels.linux_6_9;
  boot.kernelPatches = [
    {
      name = "v6.9.2-danctnix1";
      patch = ./v6.9.2-danctnix1.patch;
    }
  ];
  system.stateVersion = "24.05";
}
