# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  blockedHosts = pkgs.fetchurl {
    url = "https://someonewhocares.org/hosts/zero/hosts";
    sha256 = "changeme";
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

  networking.hostName = "link-x250"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false; 
    networkmanager.enable = true;
    interfaces = {
      enp0s25.useDHCP = true;
      wlp3s0.useDHCP = true;
    };
    extraHosts = ''
      ${builtins.readFile blockedHosts}
    '';

  };

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Allow nonfree packages
  nixpkgs.config.allowUnfree = true;

  # Package overrides
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget vim steam tdesktop lutris wineWowPackages.staging minecraft vscode gnome3.gedit 
    gnome3.gnome-terminal firefox-wayland celluloid strawberry gnome3.file-roller noto-fonts 
    nerdfonts noto-fonts-cjk noto-fonts-emoji plata-theme papirus-icon-theme transmission-gtk
    gnome3.aisleriot gnome3.gnome-tweaks discord libreoffice-fresh
    git home-manager python38 hunspellDicts.es_ES mythes aspellDicts.es
    p7zip unzip unrar gnome3.gnome-calendar gst_all_1.gst-plugins-bad piper
    gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-plugins-ugly 
    gst_all_1.gst-vaapi gst_all_1.gst-libav steam-run systembus-notify
    desmume chromium ffmpegthumbnailer noto-fonts-cjk 
    android-studio nextcloud-client obs-studio libfido2 pfetch
    gtk-engine-murrine bitwarden jetbrains.idea-community obs-studio
    nextcloud-client
    adwaita-qt
  ];

  # Environment variables
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
  };

  # QT5 Theming
  qt5.platformTheme = "gnome";

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  # MariaDB config
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
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
  security.pam.services = {
    gdm.u2fAuth = true;
    sudo.u2fAuth = true;
    su.u2fAuth = true;
  };

  #Haveged daemon
  services.haveged.enable = true;

  # Undervolting the cpu
  services.undervolt = {
    enable = true;
    coreOffset = -75;
    gpuOffset = -75;
  };

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Steam dependencies
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
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

  # Enable pipewire
  services.pipewire.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Xserver configuration
  services.xserver = {
    enable = true;

    # Xserver keyboard configuration
    layout = "de";
    xkbOptions = "eurosign:e";

    # Use libinput for trackpad support
    libinput.enable = true;

    # Wacom tablet support
    wacom.enable = true;

    # Gnome3 desktop configuration
    displayManager = {
      gdm = {
        enable = true;
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
  };

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
  system.stateVersion = "21.05"; # Did you read the comment?

}

