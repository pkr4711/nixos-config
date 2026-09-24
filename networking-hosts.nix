{ config, pkgs, ... }:
{
  networking.extraHosts = ''

    # home
    192.168.200.20  controller
    192.168.200.21  compute
    192.168.200.22  storage
    192.168.200.23  osdns

    # home2
    # 192.168.0.60  controller
    # 192.168.0.231 compute
    # 192.168.0.172 storage
  '';
}
