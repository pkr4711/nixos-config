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
        # VM local testing devices for CHV
        "30-vmlocal-tap2" = {
          netdevConfig = {
            Kind = "tap";
            Name = "vmlocal-tap2";
          };
        };

        # Openstack Management devices
        "30-osmgmt-tap10" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmgmt-tap10";
          };
        };
        "30-osmgmt-tap11" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmgmt-tap11";
          };
        };
        "30-osmgmt-tap12" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmgmt-tap12";
          };
        };
        "30-osmgmt-tap13" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmgmt-tap13";
          };
        };
        "30-osmgmt-tap14" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmgmt-tap14";
          };
        };

        # Openstack storage network
        "30-osstor-tap10" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osstor-tap10";
          };
        };
        "30-osstor-tap11" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osstor-tap11";
          };
        };
        "30-osstor-tap12" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osstor-tap12";
          };
        };

        # Openstack live migration 100G
        "30-osmig-tap10" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmig-tap10";
          };
        };
        "30-osmig-tap11" = {
          netdevConfig = {
            Kind = "tap";
            Name = "osmig-tap11";
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

      "12-lan" = {
        matchConfig.Name = "enp0s20*";   # enp0s20f0u1u1
        networkConfig.Bridge = "uplink-br0";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # onboard lan device
      "11-lan" = {
        matchConfig.Name = "enp0s31f6";
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
      "30-vmlocal-tap2" = {
        matchConfig.Name = "vmlocal-tap2";
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
          "fc00:1111:2222:3333::1/64" # Unique Local Unicast test address RFC 4193
        ];
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # Openstack Management devices
      "30-osmgmt-tap10" = {
        matchConfig.Name = "osmgmt-tap10";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      # Openstack Management devices
      "30-osmgmt-tap11" = {
        matchConfig.Name = "osmgmt-tap11";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      # Openstack Management devices
      "30-osmgmt-tap12" = {
        matchConfig.Name = "osmgmt-tap12";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      # Openstack Management devices
      "30-osmgmt-tap13" = {
        matchConfig.Name = "osmgmt-tap13";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      # Openstack Management devices
      "30-osmgmt-tap14" = {
        matchConfig.Name = "osmgmt-tap14";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # Openstack Management
      "30-veth-osmgmt" = {
        matchConfig.Name = "veth-osmgmt";
        address = [
          # must match with dnsmask
          "192.168.200.1/24"
        ];
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # Openstack Storage
      "30-osstor-tap10" = {
        matchConfig.Name = "osstor-tap10";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      "30-osstor-tap11" = {
        matchConfig.Name = "osstor-tap11";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      "30-osstor-tap12" = {
        matchConfig.Name = "osstor-tap12";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      # Openstack Storage
      "30-veth-osstor" = {
        matchConfig.Name = "veth-osstor";
        address = [
          # must match with dnsmask
          "192.168.210.1/24"
        ];
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

      # Openstack live migration
      "30-osmig-tap10" = {
        matchConfig.Name = "osmig-tap10";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      "30-osmig-tap11" = {
        matchConfig.Name = "osmig-tap11";
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };
      "30-veth-osmig" = {
        matchConfig.Name = "veth-osmig";
        address = [
          # must match with dnsmask
          "192.168.220.1/24"
        ];
        linkConfig = {
          RequiredForOnline = "no";
          ActivationPolicy = "always-up";
        };
      };

    };
  };
}
