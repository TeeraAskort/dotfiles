# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "link-gl63-8rc"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false; 
    networkmanager.enable = true;
    interfaces = {
      enp3s0.useDHCP = true;
      wlo1.useDHCP = true;
    };
  };


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "es";


  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Allow nonfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim steam tdesktop lutris wineWowPackages.staging playerctl
    tilix firefox ungoogled-chromium mpv rhythmbox noto-fonts 
    nerdfonts noto-fonts-cjk noto-fonts-emoji plata-theme papirus-icon-theme transmission-gtk
    gnome3.aisleriot nvidia-offload discord
    git home-manager hunspellDicts.es_ES mythes aspellDicts.es
    p7zip unzip unrar gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-plugins-ugly 
    gst_all_1.gst-vaapi gst_all_1.gst-libav 
  ];

  # Zsh shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    vteIntegration = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "python" "man" ];
      theme = "agnoster";
    };
  };

  # Automatic garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "22:00";

  # Automatic upgrades
  system.autoUpgrade.enable = true;

  # Security
  programs.firejail.enable = true;
  security.hideProcessInformation = true;

  # Undervolting the cpu
  services.undervolt = {
    enable = true;
    coreOffset = -100;
    gpuOffset = -100;
  };

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Steam dependencies
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;

    daemon.config = {
      enable-lfe-remixing = "yes";
      lfe-crossover-freq = 20;
      default-sample-format = "s24le";
      default-sample-rate = 192000;
      alternate-sample-rate = 48000;
    };
 
    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Xserver configuration
  services.xserver = {
    enable = true;

    # Xserver keyboard configuration
    layout = "es";
    xkbOptions = "eurosign:e";

    # Use libinput for trackpad support
    libinput.enable = true;

    # Wacom tablet support
    wacom.enable = true;

    # Use nvidia drivers
    videoDrivers = [ "nvidia" ];

    # Xfce4 desktop configuration
    displayManager.defaultSession = "xfce";
 
    displayManager.lightdm = {
      greeters.gtk = {
        theme.name = "Plata-Noir";
        IconTheme.name = "Papirus-Dark";
      };
    };

    desktopManager.xfce = {
      enable = true;
      thunarPlugins = [ pkgs.xfce.thunar-archive-plugin pkgs.xfce.gvfs pkgs.xfce.thunar-volman ];
    };
  };

  services.tumbler.enable = true;

  services.picom = {
    enable          = true;
    fade            = true;
    inactiveOpacity = 0.9;
    shadow          = true;
    fadeDelta       = 4;
  };

  # Nvidia PRIME render offload support
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime = {
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.link  = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

