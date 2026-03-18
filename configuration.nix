
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
      connect-timeout = 3; # don't hang forever when binary-cache is npt reachable
      log-lines = 25;
      min-free = 268435456; # 256 MiB
      max-free = 1073741824; # 1 GiB
      experimental-features = "nix-command flakes";
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
      trusted-substituters = [
        "http://binary-cache-v2.vpn.cyberus-technology.de"
      ];
      substituters = [
        "http://binary-cache-v2.vpn.cyberus-technology.de"
      ];
      trusted-public-keys = [
        "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q=" # v2 cache
      ];
    };

    # Garbage Collection
    gc = {
      automatic = true;
      dates = "monthly";
      # Runs normal garbage-collection plus removes all NixOS generations
      # that are older than the specified time.
      options = "--delete-older-than 30d";
    };

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

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];

  networking.firewall = {
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

  systemd.network = {
    enable = true;
    netdevs = {
        # Create the bridge interface
        "20-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
        };

        "30-tap0" = {
          netdevConfig = {
            Kind = "tap";
            Name = "tap0";
          };
        };
    };
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp0s13f0*";   # enp0s13f0u3u1
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        # networkConfig = {
        #   # start a DHCP Client for IPv4 Addressing/Routing
        #   DHCP = "ipv4";
        #   # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
        #   IPv6AcceptRA = true;
        # };
        # # make routing on this interface a dependency for network-online.target
        # linkConfig.RequiredForOnline = "routable";
      };
      "30-tap" = {
        matchConfig.Name = "tap0";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "no";
      };
      "20-br0" = {
        matchConfig.Name = "br0";
        bridgeConfig = {};
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        linkConfig = {
          # or "routable" with IP addresses configured
          # or "carrier"
          RequiredForOnline = "routable";
        };
      };
      "10-wlan" = {
        matchConfig.Name = "wlan0"; # wlp0s20f3
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;

          IgnoreCarrierLoss = "3s";
          # RouteMetric = "2048";
        };
        # make routing on this interface a dependency for network-online.target
        # one of: no | routable | carrier
        linkConfig.RequiredForOnline = "no";
      };
    };
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
    cmake
    deja-dup
    dmidecode
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
    iperf
    jq
    kdePackages.krdc
    kdePackages.okular
    kubectl
    libreoffice
    libvirt
    man-pages
    man-pages-posix
    net-tools
    nmap
    openssl
    OVMF
    OVMF-cloud-hypervisor
    OVMFFull
    pciutils
    pre-commit
    pwgen
    python3
    python313Packages.pip
    rustup
    shotwell
    signal-desktop
    slack
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
  services.udev.extraRules = ''
    # Your rule goes here
    # Logitech G533 headset (adjust IDs from lsusb)
    # SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a66", MODE="0660", GROUP="audio"
    # SUBSYSTEM=="sound", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a66", MODE="0660"
  '';

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
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
