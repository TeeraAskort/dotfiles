# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  blockedHosts = pkgs.fetchurl {
    url = "https://someonewhocares.org/hosts/zero/hosts";
    sha256 = "changeme";
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

  networking.hostName = "link-340s"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false; 
    networkmanager.enable = true;
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

  # Package overrides
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget vim tdesktop lutris wineWowPackages.staging vscode 
    celluloid strawberry gnome.file-roller  
    papirus-icon-theme transmission-gtk
    gnome.aisleriot gnome.gnome-mahjongg discord 
    git brasero nicotine-plus dolphinEmu
    zip p7zip unzip unrar gnome.gnome-calendar 
    steam-run systembus-notify yt-dlp
    google-chrome ffmpegthumbnailer 
    obs-studio libfido2 pfetch
    gtk-engine-murrine lm_sensors
    parallel libreoffice-fresh
    ffmpeg-full nodejs nodePackages.npm
    python310Packages.pynvim neovim cmake python39Full gcc gnumake
    gst_all_1.gstreamer gst_all_1.gst-vaapi gst_all_1.gst-libav 
    gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-good gst_all_1.gst-plugins-base 
    mednafen mednaffe minecraft android-tools
    firefox gnome.gnome-boxes minigalaxy
    mongodb-compass yarn nextcloud-client
    myAspell mythes gimp steam pcsx2 
    adwaita-qt docker-compose postman
  ];

  # Environment variables
  environment.sessionVariables = {
    GST_PLUGIN_PATH = "/nix/var/nix/profiles/system/sw/lib/gstreamer-1.0";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # QT5 Style
  qt5.style = "adwaita-dark";

  # Font configuration
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts
    recursive
  ];

  # Enable kdeconnect
  programs.kdeconnect.enable = true;

  # Enabling thermald
  services.thermald.enable = true;

  # Enabling virtualization
  virtualisation.libvirtd.enable = true;

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.jdk;
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

  # ZramSwap
  zramSwap.enable = true;

  # Firewall config
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    22000
  ];
  networking.firewall.allowedUDPPorts = [
    22
    80
    443
    22000
    21027
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  # Enable adb service
  programs.adb.enable = true;

  # Enabling docker service
  virtualisation.docker.enable = true;

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
    lightdm.u2fAuth = true;
    sudo.u2fAuth = true;
    su.u2fAuth = true;
  };

  # Haveged daemon
  services.haveged.enable = true;

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
  };

  # Steam dependencies
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs; [
      vaapiIntel
    ];
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  hardware.pulseaudio.enable = false;

  # Enabling xwayland
  programs.xwayland.enable = true;

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

    # Gnome3 desktop configuration
    displayManager = {
      lightdm = {
        enable = true;
        greeters.enso.enable = true;
      };
    };
    desktopManager = {
      xterm.enable = false;
      cinnamon = {
        enable = true;
      };
    };
  };

  # Enable power-profiles-daemon
  services.power-profiles-daemon.enable = true;

  # EarlyOOM
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.link  = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "video" "libvirt" "docker" "adbusers" ]; # Enable ‘sudo’ for the user.
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

