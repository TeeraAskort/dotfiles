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
  blockedHosts = pkgs.fetchurl {
    url = "https://someonewhocares.org/hosts/zero/hosts";
    sha256 = "19xv78bd5xmsyv9k56cvm3a764jyafsqpwk8m79ph6w2983akip9";
  };
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
    extraHosts = ''
      ${builtins.readFile blockedHosts}
    '';

  };

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "es";

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Allow nonfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget vim steam tdesktop lutris wineWowPackages.staging minecraft vscode gnome3.gedit 
    gnome3.gnome-terminal firefox mpv srawberry gnome3.file-roller noto-fonts 
    nerdfonts noto-fonts-cjk noto-fonts-emoji plata-theme papirus-icon-theme transmission-gtk
    gnome3.aisleriot nvidia-offload gnome3.gnome-tweaks discord libreoffice-fresh
    git home-manager python38 hunspellDicts.es_ES mythes aspellDicts.es
    p7zip unzip unrar gnome3.gnome-calendar gst_all_1.gst-plugins-bad piper
    gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-plugins-ugly 
    gst_all_1.gst-vaapi gst_all_1.gst-libav steam-run systembus-notify
    desmume chromium ffmpegthumbnailer noto-fonts-cjk gnome3.evolution
    android-studio nextcloud-client obs-studio mariadb-server dbeaver-ce
    gtk-engine-murrine eclipses.eclipse-java bitwarden jetbrains.idea-community obs-studio
  ];

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  # MariaDB config
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE USER 'tiempodb'@'localhost' IDENTIFIED BY 'tiempodb';
      CREATE USER 'alderchan'@'localhost' IDENTIFIED BY 'alderchan';
      CREATE DATABASE 'tiempodb';
      CREATE DATABASE 'alderchan';
      GRANT ALL PRIVILEGES ON tiempodb.* TO 'tiempodb'@'localhost';
      GRANT ALL PRIVILEGES ON alderchan.* TO 'alderchan'@'localhost';
    ''
  };

  # Zsh shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    vteIntegration = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "python" "man" "colored-man-pages" ];
      theme = "frisk";
    };
  };

  # Automatic garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "22:00";

  # Automatic upgrades
  system.autoUpgrade.enable = true;

  # Enable apparmor
  security.apparmor.enable = true;
  services.dbus.apparmor = "enabled";

  # PAM FIDO2 support
  security.pam.u2f.enable = true;
  security.pam.services.gdm.u2fAuth = true;

  #Haveged daemon
  services.haveged.enable = true;

  # Undervolting the cpu
  services.undervolt = {
    enable = true;
    coreOffset = -100;
    gpuOffset = -100;
  };

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Steam dependencies
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;

    daemon.config = {
      lfe-crossover-freq = 20;
      default-sample-format = "float32le";
      default-sample-rate = 192000;
      alternate-sample-rate = 48000;
      default-sample-channels = 2;
      default-channel-map = "front-left,front-right";
      default-fragments = 2;
      default-fragment-size-msec = 125;
      resample-method = "src-sinc-best-quality";
      remixing-produce-lfe = "no";
      remixing-consume-lfe = "no";
      high-priority = "yes";
      nice-level = -11;
      realtime-scheduling = "yes";
      realtime-priority = 9;
      rlimit-rtprio = 9;
      daemonize = "no";
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

    # Gnome3 desktop configuration
    displayManager = {
      gdm = {
        enable = true;
        wayland = false;
        #nvidiaWayland = true;
      };
    };
    desktopManager.gnome3.enable = true;
  };

  # Excluded gnome3 packages
  environment.gnome3.excludePackages = 
    [ pkgs.epiphany pkgs.gnome3.gnome-music
      pkgs.gnome3.gnome-software pkgs.gnome3.totem
    ];

  # TLP
  services.tlp = {
    enable = true;
    settings = {
      "CPU_ENERGY_PERF_POLICY_ON_AC"="balance_power";
      "SCHED_POWERSAVE_ON_AC"=1;
    };
  };

  # EarlyOOM
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Nvidia PRIME render offload support
  hardware.nvidia = {
    powerManagement.enable = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.link  = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}

