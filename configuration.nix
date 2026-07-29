
# apply update with:
# sudo nixos-rebuild switch --flake  /home/paul/work/repos/nixos-config

# update input
# nix flake update nixpkgs


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # imports =
  #   [ # Include the results of the hardware scan.
  #     ./hardware-configuration.nix
  #   ];
  imports = [ ];

  # nix.optimise.automatic = true;
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix = {
    # Reference: https://nixos.org/manual/nix/stable/command-ref/conf-file
    settings = {

      # container tests settings START
      auto-allocate-uids = true;
      extra-system-features = [ "uid-range" ];
      # experimental-features = "nix-command flakes";
      experimental-features = [ "auto-allocate-uids" "cgroups" "nix-command flakes" ];
      # container tests settings END

      connect-timeout = 3; # don't hang forever when binary-cache is npt reachable
      log-lines = 25;
      min-free = 268435456; # 256 MiB
      max-free = 1073741824; # 1 GiB

      fallback = true;
      warn-dirty = false;
      # nix optimise the store after each and every build (for the built path)
      # by replacing identical files in the store by hard links.
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
      trusted-users = [ "root" "@wheel" ];

      # Binary Cache

      # Faster downloads from Nix binary caches (higher parallelism)
      download-buffer-size =
      512 * 1024 * 1024 # 512 MiB
      ;
      # 128 instead of 25 parallel connections for faster downloads
      http-connections = 128 # default is 25 _
      ;
      max-substitution-jobs = 128 # default is 16
      ;

      ######################
      # disabled temporary
      ######################
      # trusted-substituters = [
      #   "http://binary-cache-v2.vpn.cyberus-technology.de"
      # ];
      # substituters = [
      #   "http://binary-cache-v2.vpn.cyberus-technology.de"
      # ];
      # trusted-public-keys = [
      #   "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q=" # v2 cache
      # ];
    };

    # # Garbage Collection
    # gc = {
    #   automatic = true;
    #   dates = "monthly";
    #   # Runs normal garbage-collection plus removes all NixOS generations
    #   # that are older than the specified time.
    #   options = "--delete-older-than 30d";
    # };

    # Scheduled systemd service that optimizes all paths in the nix store
    # by replacing identical files in the store by hard links.
    optimise.automatic = true;
  };

  # Bootloader.
  # Don't accumulate unneeded stuff.
  boot.tmp.cleanOnBoot = true;
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.grub.configurationLimit = 5;

  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true; # needed for NFS

  boot.initrd.luks.devices."luks-8f577fbc-07bb-4493-bb6f-f859a3ea6682".device = "/dev/disk/by-uuid/8f577fbc-07bb-4493-bb6f-f859a3ea6682";
  networking.hostName = "mars"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelParams = [ "mitigations=off" ];

  networking.firewall = {
    enable = false;
    allowPing = true;
    rejectPackets = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 53 67 68 ];
    # Allow all traffic on tap0
    interfaces.tap0 = {
      allowedTCPPorts = [ 1 65535 ];
      allowedUDPPorts = [ 1 65535 ];
      # Or instead of ports, you can fully trust the interface:
      # allowedTCPPortRanges = [{ from = 1; to = 65535; }];
      # allowedUDPPortRanges = [{ from = 1; to = 65535; }];
    };
  };

  # Enable networking
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;

  # disable traditional networking
  networking.useDHCP = false;
  networking.wireless.enable = false;  # Avoid conflicts with iwd

  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    Settings.AutoConnect = true;
  };



  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.doc.enable = false; # /share/doc (HTML resources, etc.)
  documentation.info.enable = false; # /share/info (content for info command)
  # Just enables infrastructure, not the man-pages itself.
  documentation.man.enable = true;
  documentation.nixos.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  services.chrony.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.mfcl8690cdwcupswrapper ];
    # browsing = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # DNS
  services.resolved = {
    enable = true;

    # This leads to spurious failures?
    dnssec = "false";
  };



  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paul = {
    isNormalUser = true;
    description = "Paul Kroeher";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "kvm" "libvirtd" "docker" "vboxusers" "audio" "libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    argc
    bind
    brave
    bridge-utils
    cargo
    cdrtools
    cloud-utils
    cmake
    deja-dup
    dmidecode
    drawio
    duplicity
    duply
    file
    fio
    gcc
    git
    gitlab-timelogs
    gitlint
    gnumake
    gnupg
    google-chrome
    gparted
    headsetcontrol
    helm
    impala    # iwd wireless manager
    iperf
    jq
    kdePackages.krdc
    kdePackages.okular
    kubectl
    lazygit
    libreoffice
    libvirt
    man-pages
    man-pages-posix
    net-tools
    nmap
    openssl
    openvswitch
    OVMF
    OVMF-cloud-hypervisor
    OVMFFull
    pciutils
    pre-commit
    pwgen
    python3
    python313Packages.pip
    python313Packages.requests
    ruff
    rustup
    shotwell
    signal-desktop
    slack
    smartmontools
    sshpass
    tcpdump
    thunderbird
    tldr
    traceroute
    tree
    unzip
    usbutils
    usbutils
    util-linux
    virt-manager
    vlc
    vscodium
    wget
    whois
    yq-go
  ];

  environment.shells = with pkgs; [ zsh bash ];

  programs.htop.enable = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "z"
      ];
      theme = "agnoster";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -la";
#      edit = "sudo -e";
#      update = "sudo nixos-rebuild switch";
    };

    histSize = 100000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
    ];
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
  # services.openssh.enable = true;

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
  system.stateVersion = "25.11"; # Did you read the comment?

  # tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Logitech udev rules
  services.udev.packages = [ pkgs.headsetcontrol ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # enable openvswitch
  virtualisation.vswitch.enable = true;

  # dnsmasq service & settings for test environment
  #   interfaces: br10 and tap1[0-4]
  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    interface=["veth-host-local"];
    except-interface="lo";
    bind-interfaces= true;
    dhcp-range=["192.168.100.50,192.168.100.100,24h"];
    dhcp-option=["3,192.168.100.1"];
    dhcp-host=[
      "02:50:F2:00:01:81,192.168.100.60"  # fixed ip address of windows test vm
      "be:e3:00:00:00:01,192.168.100.70"
      ];
  };

  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=30
  '';

  # ssh server
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };


  services.nginx = {
    enable = false;
    virtualHosts."_" = {
      enableACME = false;
      forceSSL = false;
      root = "/var/www";
      extraConfig = ''
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        index index.html index.htm;
        location / {
          autoindex on;
          allow all;
        }
      '';
    };
  };
}
