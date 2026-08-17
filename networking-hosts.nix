{ config, pkgs, ... }:
{
  networking.extraHosts = ''

    # home
    192.168.8.62  controller
    192.168.8.61  compute
    192.168.8.63  storage

    # home2
    # 192.168.0.60  controller
    # 192.168.0.231 compute
    # 192.168.0.172 storage
  '';
}
