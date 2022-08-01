#!/usr/bin/env bash
set -Eeuo pipefail

switch_plmn()
{
    # NOTE: this parameter should be different with the countries the SIM connects.
    current_plmn=$(mmcli -m 0 | grep "operator id" | awk '{print substr($0, index($0, "440"))}')
    echo "The modem connects to the PLMN ${current_plmn}"
    
    # NOTE: this parameter should be different with the supported PLMN of SIM or module.
    if [ "$current_plmn" = "44010" ]
    then
        target_plmn=44020
    else
        target_plmn=44010
    fi
    
    echo "The script will switch the PLMN to ${target_plmn}"
    
    echo "Terminate the Cellular connection..."
    nmcli con down soracom
    sleep 10
    
    echo "Switch the carrier..."
    mmcli -m 0 --3gpp-register-in-operator=${target_plmn}
    sleep 10
    
    echo "Start the new Cellular connection with PLMN ${target_plmn}..."
    nmcli con up soracom
    
    # NOTE: this parameter should be different with the countries the SIM connects.
    final_plmn=$(mmcli -m 0 | grep "operator id" | awk '{print substr($0, index($0, "440"))}')
    echo "The modem switched to the PLMN ${final_plmn}"
    
    exit 0
}


# Check the user
if [ $UID != 0 ]
then
    echo "You must run this script as root. Please try again using \"sudo ./switch-jp-carrier.sh\""
    exit 1
fi

PING_SEND_NUMBER=10
ping_loss_rate=$(ping 8.8.8.8 -c ${PING_SEND_NUMBER} -I wwan0 | grep "packet loss" | awk -F ' ' '{print $6}')

if [ "$ping_loss_rate" = "" ]
then
    echo "Something wrong"
    exit 1
elif [ "$ping_loss_rate" = "100%" ]
then
    echo "No ping success"
    switch_plmn
else
    echo "there is ping success"
    exit 0
fi