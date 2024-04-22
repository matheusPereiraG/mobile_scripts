#!/bin/sh

launch_avd() {
    local avd_name="$1"
    nohup emulator -avd "$avd_name" -writable-system >/dev/null 2>&1 &
}

disable_animations() {
    adb shell settings put global window_animation_scale 0
    adb shell settings put global transition_animation_scale 0
    adb shell settings put global animator_duration_scale 0
}

enable_animations() {
    adb shell settings put global window_animation_scale 1
    adb shell settings put global transition_animation_scale 1
    adb shell settings put global animator_duration_scale 1
}

reset_proxy() {
    adb shell svc wifi disable &&
    adb shell settings put global http_proxy :0 &&
    adb shell svc wifi enable
}

get_wireless_ip() { #For ethernet try en1
    local ip_address=$(ipconfig getifaddr en0)
    echo "$ip_address"
}

set_http_proxy() {
    # Check if the adb command is available
    if ! command -v adb &> /dev/null; then
        echo "Error: adb command not found. Make sure Android SDK is installed."
        exit 1
    fi

    # Check if the device is connected
    if ! adb devices | grep -q -w device; then
        echo "Error: No Android device connected."
        exit 1
    fi

    local port="$1"
    local local_ip=$(get_wireless_ip)

    #For wireless: ipconfig getifaddr en0
    #For ethernet: ipconfig getifaddr en1

    # Set HTTP proxy on the device
    adb shell settings put global http_proxy "$local_ip:$port"

    adb shell svc wifi disable
    adb shell svc wifi enable

    echo "HTTP proxy set to $local_ip:$port on the Android device."
}