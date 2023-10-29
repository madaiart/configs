# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # '<home-manager>'
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-5625a410-d9c8-4f06-a983-ae129f8d3139".device = "/dev/disk/by-uuid/5625a410-d9c8-4f06-a983-ae129f8d3139";
  boot.initrd.luks.devices."luks-5625a410-d9c8-4f06-a983-ae129f8d3139".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.wireless.networks = {
    Xiaomi_0C38_5G = {
      psk = "D0omsd@y_1.5";
    };
  };
  networking.nameservers = ["8.8.8.8" "8.8.4.4"];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";
  networking.resolvconf.enable = pkgs.lib.mkForce false;
  services.resolved.enable = false;
 # networking.networkmanager.dsn = "none";

  services.udev.extraRules = ''
    # Allow access to kindle
    SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666"
  '';

  # Set your time zone.
  time.timeZone = "America/Guayaquil";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_EC.UTF-8";
    LC_IDENTIFICATION = "es_EC.UTF-8";
    LC_MEASUREMENT = "es_EC.UTF-8";
    LC_MONETARY = "es_EC.UTF-8";
    LC_NAME = "es_EC.UTF-8";
    LC_NUMERIC = "es_EC.UTF-8";
    LC_PAPER = "es_EC.UTF-8";
    LC_TELEPHONE = "es_EC.UTF-8";
    LC_TIME = "es_EC.UTF-8";
  };

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 

  # Enable the X11 windowing system.
  services.xserver = {
     enable = true;

     # Enable i3
     desktopManager = {
        xterm.enable = false;
     # plasma5.enable = true;   # Enable the KDE Plasma Desktop Environment.

     };
   
     displayManager = {
        defaultSession = "none+i3";
      # sddm.enable =true;   # Enable the KDE Plasma Desktop Environment.
     };

    #videoDrivers = [ "displaylink" "modesetting" ];
     windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
          i3-gaps
        ];
     };
  };
  

 services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 3840x2160 --pos 3840x0 --rotate right --brightness 0.6 --scale 1.5x1.5 
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1-1 --primary --pos 0x1920 --brightness 0.6 --scale 2x2
    ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1-1 --off
    '';

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
#    xkbOptions ="esc:swapcaps";
       };


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.browsedConf = ''
	BrowseDNSSDSubTypes _cups,_print
	BrowseLocalProtocols all
	BrowseRemoteProtocols all
	CreateIPPPrinterQueues All

	BrowseProtocols all
	    '';
   services.avahi = {
     enable = true;
     nssmdns = true;
   };
  

  # NVIDIA official drivers
   hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
   };
   services.xserver.videoDrivers = ["nvidia"];
 
   hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
         # Activate the card allways
        sync.enable = true;

        # Offload use in certain sotware
        # offload = {
        #    enable = true;
        #    enableOffloadCmd = true;
        # };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        };
   };
 
   # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     # If you want to use JACK applications, uncomment this
     #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.madai = {
    isNormalUser = true;
    shell = pkgs.bash;
    description = "Madai";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "docker"];
    packages = with pkgs; [   
      kate
      alacritty
      obsidian
      keepass
      calibre
      flameshot
      slack
      copyq
      obs-studio
      peek
      remmina
      zoom-us
      google-chrome
      chromium
      vlc
      unzip
      dbeaver
      virt-manager
      kvmtool
      rofi
      #arandr
      libnotify
      picom 
      betterlockscreen
      docker
      lazydocker
      vscode
      postgresql_15
      
      
      #Console
      ffmpeg
      hstr
      ranger
      hstr
      starship
      pipx
      ripgrep
      tree-sitter
      htop
      xclip
      fd
      gh
      lazygit
      awscli2
      ssm-session-manager-plugin
      zellij
      nushell
      mtpfs


      #Programming
      git
      conda
      gcc
      # nodejs
      nodePackages.prettier
      yarn
      cypress

      # Optional
      # sysstat

    # firefox
    # wine64
    # thunderbird
    ];
  };

   # home-manager.users.madai = {pkgs, ...}:{
   #    home.packages = [pkgs.atool pkgs.httpie];
   #    programs.bash.enable = true;
   # };
  
  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "madai";
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.permittedInsecurePackages = [
     "openssl-1.1.1u"
     "nvidia-x11"
     "nvidia-setting"
     "nvidia-persistenced"
     ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  # wget
  beekeeper-studio 
  lxappearance
  neovim
  # tmux 	
  ];

  fonts.fonts = with pkgs;
     [
        (nerdfonts.override {
           fonts = ["FiraCode" "FiraMono" "Hack" "DroidSansMono"];
        })
     ];

  # Allow virtualiztion
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  virtualisation.docker.rootless = {
  enable = true;
  setSocketVariable = true;
  };

  # Filesystem mounting
# fileSystems."/mnt/virtual" = {
# options = [ "defaults" ];
# };

  fileSystems."/mnt/my_partition" = {
   device = "/dev/sdc3";
   fsType = "ntfs";
   options = [ "defaults" ];
  };

  systemd.services.start-virsh-default-network = {
  description = "Start the virsh default network";
  after = [ "libvirtd.service" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "/usr/bin/virsh net-start default";
    RemainAfterExit = true;
   };
  };





  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
