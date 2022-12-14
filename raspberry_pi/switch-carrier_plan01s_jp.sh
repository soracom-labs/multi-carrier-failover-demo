#!/usr/bin/env bash
set -Eeuo pipefail

switch_plmn()
{
    current_plmn=$(mmcli -m 0 | grep -oP "(?<=operator id: )\d+")
    echo "The modem connects to the PLMN ${current_plmn}"

    # NOTE: this parameter should be different with the countries the SIM connects or the supported PLMN of SIM / module.
    if [ "${current_plmn}" = "44010" ]
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
    final_plmn=$(mmcli -m 0 | grep -oP "(?<=operator id: )\d+")

    if [ "${final_plmn}" = "${target_plmn}" ]
    then
        echo "The modem successfully switched to the PLMN ${final_plmn}"
        exit 0
    else
        echo "Error. the modem did not switch to the PLMN ${target_plmn}. Current PLMN is ${final_plmn}"
        exit 1
    fi
}


# Check the user
if [ $UID != 0 ]
then
    echo "You must run this script as root. Please try again using \"sudo $0\""
    exit 1
fi

count=${COUNT:-10}
echo "Begin ping monitoring. The scipt will send ping ${count} times."

# When ping_loss_rate is 100%, the ping status code is `1`.
set +e
ping_loss_rate=$(ping 8.8.8.8 -c "$count" -I wwan0 -s 2 -w 5 | grep -oP "\d+%(?= packet loss)")
set -e

if [ "${ping_loss_rate}" = "" ]
then
    echo "Error. Something wrong"
    exit 1
elif [ "${ping_loss_rate}" = "100%" ]
then
    echo "No ping success"
    switch_plmn
else
    echo "There is ping success"
    exit 0
fi
