# Setting up mitmproxy with android

## User certificate
- Move to sd card
```bash
adb push ~/.mitmproxy/mitmproxy-ca-cert.cer /storage/emulated/0/Download/mitmproxy-ca-cert.cer
```
- Set http proxy in device
```bash
source avd_functions 
set_http_proxy 8080
```

- Reset wifi state
```bash
adb shell svc wifi disable
adb shell svc wifi enable
```

## System certificate
Follow ./android_system_ca_wizard <br>
Note: Install only these certificate on a emulator deprived of google play services. 