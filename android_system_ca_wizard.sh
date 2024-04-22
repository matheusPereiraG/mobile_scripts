#!/bin/sh
#Reference: https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/

source avd_functions.sh

echo "Warning, this script only works for api level > 28 and emulators with no google play services"
echo

#Generate cert
readonly MY_CERT_NAME="mitmproxy-ca-cert.cer"
readonly MY_CERT_PATH="$HOME/.mitmproxy/"
echo "This is your certificate path: $MY_CERT_PATH"
echo "Generating android hashed name certificate..."
hashed_name=`openssl x509 -inform PEM -subject_hash_old -in "$MY_CERT_PATH/$MY_CERT_NAME" | head -1` && cp "$MY_CERT_PATH/$MY_CERT_NAME" "$MY_CERT_PATH/$hashed_name.0"
echo "Generated $hashed_name" 
echo 

# Get the list of available AVDs
avd_list=$(emulator -list-avds)

# Check if there are no AVDs
if [ -z "$avd_list" ]; then
    echo "No AVDs found. Exiting."
    exit 1
fi

# Print the list of AVDs with numbers
echo "Available AVDs:"
echo "$avd_list" | awk '{print NR, $0}'

# Prompt the user to select an AVD
read -p "Enter the number of the desired AVD: " avd_number

# Validate the user input
if ! [[ "$avd_number" =~ ^[1-9][0-9]*$ ]] || [ "$avd_number" -gt $(echo "$avd_list" | wc -l) ]; then
    echo "Invalid input. Exiting."
    exit 1
fi

# Get the selected AVD name
selected_avd=$(echo "$avd_list" | awk -v avd_number="$avd_number" 'NR==avd_number {print $0}')

# Use the selected AVD
echo "Selected AVD: $selected_avd"

echo "Launching avd as a writable system"
launch_avd $selected_avd

echo
echo "Now wait for the system to boot, then click enter to root device"
read -r

echo "Rooting device..."
adb root
echo
echo "Press enter to continue"
read -r 

echo "Disabling boot verification"
adb shell avbctl disable-verification
echo
echo "Press enter to continue"
read -r 

echo "Rebooting device"
adb reboot
echo
echo "Press enter to continue"
read -r 

echo "Rooting again"
adb root
echo
echo "Press enter to continue"
read -r

echo "Remounting"
adb remount
echo
echo "Press enter to continue"
read -r

echo "Pushing created cert" 
adb push "$MY_CERT_PATH/$hashed_name.0" /system/etc/security/cacerts
echo
echo "Press enter to continue"
read -r

echo "Set certificate perms"
adb shell chmod 664 /system/etc/security/cacerts/$hashed_name.0
echo
echo "Press enter to continue"
read -r

echo "Rebooting... and we're done. Now you just need to setup the proxy http on settings"
adb reboot