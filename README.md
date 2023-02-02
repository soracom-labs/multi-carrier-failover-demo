[![test](https://github.com/soracom-labs/multi-carrier-demo/workflows/test/badge.svg)](https://github.com/soracom-labs/multi-carrier-demo/actions/workflows/test.yaml)

# Multi Carrier Failover Demo

## Overview

The script in this repository shows an example of failover across carriers for a SIM with multi-carrier connectivity.

For example, [raspberry_pi/plan01s_jp/switch_carrier.sh](raspberry_pi/switch-carrier_plan01s_jp.sh) switches the carrier from NTT Docomo to SoftBank (or vice versa) when a ping loss occurs.

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

In the script, supported carriers are hard-coded as PLMN (Public Land Mobile Network) Number (e.g. 44010 as NTT Docomo). You may find current PLMN (MCC + MNC) in `Soracom User Console > SIM Management > session detail`. If you need to check the PLMNs of other support carrier, you may see them when switching the carriers using Smartphones. You can also find a list of possible PLMN codes on https://www.mcc-mnc.com/ . 
Please also note that supported carriers depend on the SIM type and the region in which the device is located. Please confirm the SIM type and region.

| Script | SIM type | Region |
| :---  | :--- | :--- |
| [switch-carrier_plan01s_jp.sh](raspberry_pi/switch-carrier_plan01s_jp.sh) | plan01s | Japan |
| [switch-carrier_plan01s_us.sh](raspberry_pi/switch-carrier_plan01s_us.sh) | plan01s | United States |

### Software

The script uses Network Manager to connect device to Soracom platform. Please invoke following commands to set up.

**NOTE**

- If you have already set up the Network Manager or Wvdial, some of the following commands may not be necessary or will cause conflicts. To try this demo, please consider setting up with a clean installed Raspberry Pi OS. 
- If you SSH to Raspberry Pi via Wi-Fi, you may experience connectivity loss during installing network-manager. In such case, please wait a while or reboot the device and SSH again.
- If you want to route more traffic through Soracom platform, invoke another `sudo nmcli con modify soracom +ipv4.routes "xxx.xxx.xxx.xxx/xx 0.0.0.0 0"` command (Use your IP address for `xxx.xxx.xxx.xxx` and prefix for `/xx`). You can also invoke `sudo nmcli con modify soracom ipv4.route-metric 0` to route all traffic through Soracom platform.

```bash
# Install a package "Network Manager" for cellular connection
sudo apt update && sudo apt install network-manager
# Configure Network Manager to connect to the Soracom platform
sudo nmcli con add type gsm ifname "*" con-name soracom apn soracom.io user sora password sora
# Set up a connection to the Soracom platform using Network Manager
echo "denyinterfaces wwan0" >> /etc/dhcpcd.conf
# Route traffic to Soracom platform services through soracom interface
sudo nmcli con modify soracom +ipv4.routes "100.127.0.0/16 0.0.0.0 0, 54.250.252.67/32 0.0.0.0 0, 54.250.252.99/32 0.0.0.0 0"
# Route traffic to Google Public DNS (8.8.8.8) through soracom interface
sudo nmcli con modify soracom +ipv4.routes "8.8.8.8/32 0.0.0.0 0"
# Reboot to reflect settings
sudo reboot now
# Confirm the device has connected to Soracom platform
ping pong.soracom.io -c 4
```

## How It Works

1. The script checks the ping loss rate to [Google Public DNS](https://developers.google.com/speed/public-dns) (8.8.8.8)
2. If there's 100% ping loss rate, the script calls `switch_plmn` function
3. `switch_plmn` function uses mmcli to
 - check the carrier the device is currently connected
 - switch the carrier to other supported one
4. `switch_plmn` function uses nmcli to down/up the cellular connectivity interface

**NOTE**:

- If switching the carrier fails, please consider extending the `sleep` time.
- If you do not want to ping to Google Public DNS, please update the script and the routing configuration.

## Warning

The script in this repository is example only and is not guaranteed to work. In addition, the content of this script is not intended for commercial use. Please use them at your own risk.
