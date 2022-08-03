[![test](https://github.com/soracom-labs/multi-carrier-demo/workflows/test/badge.svg)](https://github.com/soracom-labs/multi-carrier-demo/actions/workflows/test.yaml)

# Multi Carrier Switch Demo

## Overview

The script in this repository shows an example of switching carriers for multi-carrier connectable SIMs.

For example, [plan01s_jp/switch_carrier.sh](plan01s_jp/switch-carrier.sh) switches the carrier from NTT Docomo to SoftBank (or vice versa) when a ping loss occurs.

## Prerequisites

Please follow the following prerequisites to use the script.

### Hardware

The script has been tested with the combination of the following:

- Raspberry Pi
- Soracom Onyx LTE USB Modem
- Soracom IoT SIM

### Raspberry Pi OS

The script has been tested with Raspberry Pi OS Lite, bullseye (2022-04-04).

### SIM type and region

In the script, supported carriers are hard-coded as PLMN (Public Land Mobile Network) Number (e.g. 44010 as NTT Docomo). Please find a list of possible PLMN codes e.g. on https://www.mcc-mnc.com/  .
Supported carriers depend on the SIM type and the region in which the device is located. Please confirm the SIM type and region.

| Script | SIM type | Region |
| :---  | :--- | :--- |
| [plan01s_jp/switch_carrier.sh](plan01s_jp/switch-carrier.sh) | plan01s | Japan |

### Software

The script uses Network Manager to connect device to Soracom platform. Please invoke following commands to set up.

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

## Warning

The script in this repository is example only and is not guaranteed to work. In addition, the content of this script is not intended for commercial use. Please use them at your own risk.
