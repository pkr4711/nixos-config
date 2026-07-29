{ config, pkgs, ... }:

{

  systemd.network = {
    enable = true;
    netdevs = {
        # Create the bridge interface
        "20-uplink-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "uplink-br0";
          };
        };

        # VM local testing devices for CHV
        "30-vmlocal-tap0" = {
          netdevConfig = {
            Kind = "tap";
            Name = "vmlocal-tap0";
          };
        };
        # VM local testing devices for CHV
        "30-vmlocal-tap1" = {
          netdevConfig = {
            Kind = "tap";
            Name = "vmlocal-tap1";
          };
        };
    };
    networks = {

      # bridged LAN interface
      "10-lan" = {
        matchConfig.Name = "enp0s13f0*";   # enp0s13f0u3u1
        networkConfig.Bridge = "uplink-br0";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # none bridged wlan
      "10-wlan" = {
        matchConfig.Name = "wlan0"; # wlp0s20f3
        dhcpV4Config = {
          RouteMetric = 200;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 200;
        };
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

      "20-uplink-br0" = {
        matchConfig.Name = "uplink-br0";
        bridgeConfig = {};
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 100;
        };
        dhcpV4Config = {
          RouteMetric = 100;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };

      # VM local testing devices for CHV
      "30-vmlocal-tap0" = {
        matchConfig.Name = "vmlocal-tap0";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # VM local testing devices for CHV
      "30-vmlocal-tap1" = {
        matchConfig.Name = "vmlocal-tap1";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # VM local testing devices for CHV
      "30-veth-host-local" = {
        matchConfig.Name = "veth-host-local";
        address = [
          # must match with dnsmask
          "192.168.100.1/24"
        ];
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
    };
  };
}
