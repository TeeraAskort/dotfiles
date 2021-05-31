# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  blockedHosts = pkgs.fetchurl {
    url = "https://someonewhocares.org/hosts/zero/hosts";
    sha256 = "0w8jpiidd86d04clwqn682rj6j3r8rq1xkyb99nf46smbn14lqpk";
  };
  myAspell = pkgs.aspellWithDicts(ps: with ps; [
    es
    en
  ]);
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "link-pc"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false; 
    networkmanager.enable = true;
    interfaces = {
      enp2s0.useDHCP = true;
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

  # Package overriding
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: [
        pkgs.ibus
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./materia-theme {})
    (pkgs.callPackage ./materia-kde {})
    wget vim tdesktop lutris wineWowPackages.staging minecraft vscode gnome.gedit 
    gnome.gnome-terminal firefox celluloid strawberry gnome.file-roller  
    papirus-icon-theme transmission-gtk
    gnome.aisleriot gnome.gnome-tweaks discord 
    git home-manager python38 
    p7zip unzip unrar gnome.gnome-calendar 
    steam-run systembus-notify
    desmume google-chrome ffmpegthumbnailer 
    nextcloud-client obs-studio libfido2 pfetch
    gtk-engine-murrine 
    parallel libreoffice-fresh
    ffmpeg-full nodejs nodePackages.npm
    python39Packages.pynvim neovim cmake python39Full gcc gnumake
    gst_all_1.gstreamer gst_all_1.gst-vaapi gst_all_1.gst-libav 
    gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-good gst_all_1.gst-plugins-base
    android-studio libsForQt5.qtstyleplugin-kvantum
    mednafen mednaffe lbry
    
    myAspell mythes steam
  ];

  # VPN configuration
  services.libreswan.enable = true;
  services.xl2tpd.enable = true;

  # Environment variables
  environment.sessionVariables = {
    GST_PLUGIN_PATH = "/nix/var/nix/profiles/system/sw/lib/gstreamer-1.0";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # Font configuration
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts
    recursive
  ];

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
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

  #Haveged daemon
  services.haveged.enable = true;

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Steam dependencies
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    driSupport = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
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
      resample-method = "speex-float-5";
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
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

  # Enable pipewire
  services.pipewire.enable = true;

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

    # AMDGPU drivers
    videoDrivers = [ "amdgpu" ];

    # Gnome3 desktop configuration
    displayManager = {
      gdm = {
        wayland = false;
        enable = true;
      };
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.interface]
        gtk-theme = "Materia-dark-compact"
        icon-theme = "Papirus-Dark"
	      monospace-font-name = "Rec Mono Semicasual Regular 11"

        [org.gnome.desktop.wm.preferences]
        theme = "Materia-dark-compact"
        button-layout = "appmenu:minimize,maximize,close"

	[org.gnome.desktop.peripherals.mouse]
	accel-profile = "flat"

	[org.gnome.desktop.privacy]
	disable-camera = true
	disable-microphone = true
	remember-recent-files = false
	remove-old-temp-files = true
	remove-old-trash-files = true
	old-files-age = 3

        [org.gnome.settings-daemon.plugins.power]
        sleep-inactive-ac-timeout = 1800
        sleep-inactive-battery-timeout = 900
      '';
    };
  };

  # Excluded gnome3 packages
  environment.gnome.excludePackages = 
    [ pkgs.epiphany pkgs.gnome.gnome-music
      pkgs.gnome.gnome-software pkgs.gnome.totem
    ];

  # EarlyOOM
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
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
  system.stateVersion = "21.11"; # Did you read the comment?

}

