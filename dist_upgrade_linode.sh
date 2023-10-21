#!/bin/bash
# Script Name: dist_upgrade_linode.sh
# Description: This Script makes the distro upgrade safely. It integrates Linode's API by taking a Snapshot before starting
# the upgrade and, if it doesn't work, it returns to the previous configuration through the Snapshot.
# Author: João Pedro Hagen
# E-mail: joaopedro@hagen.dev.br
echo ' ________ _____         _____         _____  __                                  _________ ';
echo ' ___  __ \___(_)__________  /_        __  / / /________ _______ _______________ _______  /_____ ';
echo ' __  / / /__  / __  ___/_  __/_________  / / / ___  __ \__  __ `/__  ___/_  __ `/_  __  / _  _ \ ';
echo ' _  /_/ / _  /  _(__  ) / /_  _/_____// /_/ /  __  /_/ /_  /_/ / _  /    / /_/ / / /_/ /  /  __/ ';
echo ' /_____/  /_/   /____/  \__/          \____/   _  .___/ _\__, /  /_/     \__,_/  \__,_/   \___/ ';
echo '                                               /_/      /____/ ';
sleep 3;
echo;
API_KEY='YOUR API KEY HERE'
LINODE_ID=$(cat /sys/devices/virtual/dmi/id/product_serial)
UBUNTU_VERSION=$(lsb_release -r -s)
LIST_SITES=$("ls" /srv/ | grep -E '\.(com|org|net|edu|gov|mil|info|biz|co|io|adv|dev)' | grep -v '.configr.cloud')
# If you want to enable recovery mode, just change RECOVERY_MODE variable to true
RECOVERY_MODE=false
# If you want to enable the upgrade only to 16.04 version, just change UPGRADE_16_ONLY variable to true
UPGRADE_16_ONLY=true
# If you want to enable the upgrade interactive mode, chage this variable to true
UPGRADE_INTERACTIVE=false
# This function is only used if RECOVERY_MODE is set to true.
recovery () {
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32mUpdate completed successfully\e[0m";
        sleep 3;
        echo;
        if [ "$UBUNTU_VERSION" == '18.04' ]; then
            echo "Reinstall safe-rm";
            apt install safe-rm -y > /dev/null 2>&1;
            sleep 3;
        fi
        echo;
        echo "Rebooting the system..."
        sleep 3;
        reboot;
    else
        SNAP_STATUS=$(jq '.status' /root/.snapstatus.json 2>/dev/null)
        echo -e "\e[1;31mAn error occurred in the update\e[0m";
        sleep 3;
        echo "Don't worry. We are returning the server to its pre-upgrade state.";
        echo "Remember to turn on the server after the restore process.";
        sleep 3;
        apt-get install --reinstall libc6 > /dev/null 2>&1;
        echo "Deploying Snapshot...";
        echo;
        wget --header="Content-Type: application/json" \
            --header="Authorization: Bearer $API_KEY" \
            --post-data='{"linode_id":'"$LINODE_ID"',"overwrite":true}' \
            -O /root/.snaprestore.json \
            https://api.linode.com/v4/linode/instances/"$LINODE_ID"/backups/"$SNAP_ID"/restore > /dev/null 2>&1;
    fi
}
if [ "$UPGRADE_16_ONLY" == true ] && [ "$UBUNTU_VERSION" == '18.04' ]; then
        echo "Your distro version is already 18.04";
        exit 0;
fi
# Installation of jq to handle json data
echo -e "\e[1;35mInstalling jq for json handling...\e[0m";
sleep 3;
apt install jq -y > /dev/null 2>&1;
# Take a new Snapshot
echo -e "\e[1;35mTaking the Snapshot. Wait until the next step. This usually takes time.\e[0m";
echo;
sleep 5;
curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -X POST -d '{
        "label": "Backup_Distro_Upgrade"
    }' \
    https://api.linode.com/v4/linode/instances/"$LINODE_ID"/backups > /root/.snaplog.json 2> /dev/null;
# Check Snapshot status
while [ "$SNAP_STATUS" != '"successful"' ]
do
    SNAP_ID=$(jq '.id' /root/.snaplog.json)
    SNAP_STATUS=$(jq '.status' /root/.snapstatus.json 2>/dev/null)
    curl -H "Authorization: Bearer $API_KEY" \
        https://api.linode.com/v4/linode/instances/"$LINODE_ID"/backups/"$SNAP_ID" > /root/.snapstatus.json 2> /dev/null;
done
echo -e "\e[1;35mSnapshot completed successfully!\e[0m";
sleep 3;
echo -e "\e[1;35mStarting distro upgrade. This may take some time. Wait until the terminal becomes available again.\e[0m";
echo;
# Change the prompt value=lts to value=normal.
sed -i 's/^Prompt=.*/Prompt=normal/' /etc/update-manager/release-upgrades;
echo 'Accepting third-party repositories.'
echo "[Sources]" >> /etc/update-manager/release-upgrades.d/allow-third-party.cfg;
echo "AllowThirdParty = yes" >> /etc/update-manager/release-upgrades.d/allow-third-party.cfg;
apt autoclean -y > /dev/null 2>&1;
echo "Fixing possible packages with errors";
apt-get --fix-broken install -y;
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4528B6CD9E61EF26;
sleep 2;
echo "Updating repositories";
apt update > /dev/null 2>&1;
sleep 2;
echo "Installing update-manager-core";
apt install update-manager-core -y > /dev/null 2>&1;
sleep 2;
echo "Updating packages";
export DEBIAN_FRONTEND=noninteractive
apt-get -y --allow-unauthenticated -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade;
sleep 2;
# The 18.04 versions are experiencing issues with libcrypt.so.1.
# After conducting several searches, I managed to work around the problem by
# removing safe-rm and then reinstalling it.
if [ "$UBUNTU_VERSION" == '18.04' ]; then
    echo 'Removing safe-rm';
    apt purge safe-rm -y > /dev/null 2>&1;
fi
echo "Starting do-release-upgrade";
sleep 3;
if [ "$UPGRADE_INTERACTIVE" = false  ]; then
    do-release-upgrade -f DistUpgradeViewNonInteractive -q; # Non-interactive mode. No user decision. All settings are default.
else
    echo -e "\e[1;31mWARNING!\e[0m Choose next options carefully.";
    sleep 3;
    do-release-upgrade;
fi
if [ "$RECOVERY_MODE" == false ]; then
    echo -e "\e[1;32mUpdate completed successfully\e[0m";
    echo -e "\e[1;32mPLEASE RESTART THE SYSTEM. IF YOU HAVE AN\e[0m \e[1;31mERROR\e[0m, \e[1;32mRETURN THE SNAPSHOT TAKEN EARLIER.\e[0m";
    echo;
    #echo "Rebooting the system..."
    #sleep 3;
    #reboot;
    echo
    if [ "$UBUNTU_VERSION" == '18.04' ]; then
        echo "Reinstall safe-rm";
        apt install safe-rm -y;
        sleep 3;
    fi
else
    recovery;
fi
