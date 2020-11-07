# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];

  boot.initrd.luks.devices."luks" = {
    device = "/dev/disk/by-uuid/cdda911a-9545-4226-88a6-87e95aa44a2a";
    allowDiscards = true;
    preLVM = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2c2b45f5-76ae-4040-aca7-1d62a23471e5";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A86B-B09A";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/fd585478-7049-4c80-9a5d-0242bb71a492";
      fsType = "ext4";
    };

  fileSystems."/home/link/Datos" = {
    encrypted = {
      blkDev = "/dev/disk/by-uuid/20976b67-c796-47c9-90dd-62c1edc34258";
      enable = true;
      keyFile = "/mnt-root/.keyfile";
      label = "encrypteddata";
    };
    device = "/dev/mapper/encrypteddata";
    fsType = "ext4";
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/912fd6c5-820c-4e3e-8d62-722ff8bf12c7"; }
    ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
