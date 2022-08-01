# Multi Carrier Demo

## Overview

The scripts in this repository shows sample of switching carriers for multi-carrier connectable SIMs.

For example, [plan01s_jp/switch_carrier.sh](plan01s_jp/switch-carrier.sh) switches the carrier from NTT Docomo to SoftBank (or vice versa) when a ping loss occurs.

## Prerequisite

For example, if you use Soracom Onyx LTE USB Modem + Raspberry Pi, run the following commands:

```bash
# Install a package "Network Manager" for cellular connection
sudo apt-get install network-manager
# Configure Network Manager to connect to the Soracom platform
sudo nmcli con add type gsm ifname "*" con-name soracom apn soracom.io user sora password sora
# Set up a connection to the Soracom platform using Network Manager
echo "denyinterfaces wwan0" >> /etc/dhcpcd.conf
# Set all communication to be routed via Soracom
sudo nmcli con modify soracom ipv4.route-metric 0
# Reboot to reflect settings
sudo reboot now
```

## How It Works

1. The script checks the ping loss rate
2. If there's 100% ping loss rate, the script calls `switch_plmn` function
3. `switch_plmn` function uses mmcli to
 - check the carrier the device is currently connected
 - switch the carrier to other supported one
4. `switch_plmn` function uses nmcli to down/up the cellular connectivity interface

NOTE: In scripts, the supported carrier is hard-coded as PLMN (Public Land Mobile Network) Number (e.g. 44010 as NTT Docomo).

## Warning

The sketches in this repository are examples only and are not guaranteed to work. In addition, the content of this sketch is not intended for commercial use. Please use them at your own risk.
