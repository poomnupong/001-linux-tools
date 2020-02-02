#!/bin/bash
###
# Date: 2020.02.02
# By: Poom Nupong (poomsawas@gmail.com)
###
# !! Provided with no warranty. by using this script you agree that I take no responsibility for any damage caused by this script. Use at your own risk. !!
# Type: bash script
# Purpose: set static IP address on Ubuntu 18.04+ that start with cloud-init
# How to use:
# - set network parameters in variable section then run the script
# - check destination location of the file
# What it does:
# - delete original netplan file
# - create a new one with static network parameters
###

# location of involved files, from Ubuntu 19.10
FILE_ORG_CLOUD_INIT="/etc/netplan/50-cloud-init.yaml"
FILE_CLOUDINIT_NETDISABLE="/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
FILE_NETCFG="/etc/netplan/01-netcfg.yaml"

# set network parameters here
IP_ADDR="192.168.1.11/24"
IP_GW="192.168.1.11"
IP_DNS="208.67.222.222,208.67.220.220"

# delete original cloud-init generated netplan file - usually dhcp
if [ -f "$FILE_ORG_CLOUD_INIT" ]; then
  rm /etc/netplan/50-cloud-init.yaml
fi

# disable network config on cloud-init
cat > $FILE_CLOUDINIT_NETDISABLE <<EOF
network: {config: disabled}
EOF

# write yaml network config to destination file
cat > $FILE_NETCFG <<EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [$IP_ADDR]
      gateway4: $IP_GW
      nameservers:
        addresses: [$IP_DNS]
EOF

#apply netplan (or reboot)
/usr/sbin/netplan apply