#!/bin/bash

# Usage:
#   ./reference-debloat-script.sh ZHLJJNVGAYHUP7QC
# or just run without args to auto-pick the first connected device.

DEVICE_SERIAL="$1"

# Auto-select the first connected device if no serial is provided
if [ -z "$DEVICE_SERIAL" ]; then
  DEVICE_SERIAL=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')
fi

if [ -z "$DEVICE_SERIAL" ]; then
  echo "No device connected. Connect your device and enable USB debugging."
  exit 1
fi

echo "Using device: $DEVICE_SERIAL"

# List of packages to debloat
packages=(

# --- Google Bloatware (Optional) --- 
com.google.android.dialer # Phone 
com.google.android.contacts # Contacts 
com.google.android.apps.messaging # Messages 
com.google.android.gm # Gmail 
com.google.android.deskclock # Clock 
com.google.android.calculator # Calculator 
com.google.android.inputmethod.latin # Gboard 
com.google.android.apps.photosgo # Gallery 
com.google.android.apps.photos # Photos 
com.google.android.apps.nbu.files # Files 
#com.google.android.webview # Webview 
com.google.android.apps.maps # Maps 
#com.google.android.gms # Google Play Services 
com.android.vending #Playstore 
com.google.android.apps.wellbeing # Digital Well-being 
com.google.android.marvin.talkback # Optional 
com.google.android.accessibility.soundamplifier # Optional

# --- Eye Protection Features (Keep) --- 
#com.coloros.uxdesign # Night Light Scheduling 
#com.coloros.eyeprotect # Eye Comfort Mode

# --- Google Bloatware ---
com.google.android.youtube
com.android.chrome
com.google.android.apps.docs
com.google.ar.lens
com.google.android.keep
com.google.android.apps.nbu.paisa.user
com.google.android.apps.tachyon
com.google.android.apps.youtube.music
com.google.android.apps.meetings
com.google.android.videos
com.google.android.projection.gearhead
com.google.android.apps.podcasts
com.google.android.apps.magazines
com.google.android.music
com.google.android.feedback
com.google.android.googlequicksearchbox
com.google.android.calendar
com.google.android.apps.translate
com.google.ar.core

# --- Facebook Pre-installs ---
com.facebook.app
com.facebook.services
com.facebook.appmanager
com.facebook.system
com.facebook.katana

# --- Realme / HeyTap / ColorOS Bloatware ---
com.heytap.cloud
com.heytap.market
com.heytap.themestore
com.heytap.openid
com.heytap.pictorial
com.heytap.usercenter
com.coloros.childrenspace
com.coloros.smartsidebar
com.coloros.focusmode
com.coloros.gamespace
com.coloros.assistantscreen
com.coloros.sceneservice
com.coloros.securitycheck
com.coloros.screenrecorder
com.coloros.systemclone
com.coloros.oppomultiapp
com.coloros.sauhelper
com.coloros.logkit
com.coloros.sau
com.coloros.smartdrive
com.coloros.deepthinker
com.coloros.backuprestore
com.coloros.wallpapers
com.coloros.translate.engine
com.coloros.karaoke
com.coloros.healthcheck
com.coloros.lockassistant
com.coloros.simsettings
com.coloros.ocs.opencapabilityservice
com.coloros.encryption
com.coloros.athena
com.android.fmradio
com.coloros.oshare
com.coloros.phonemanager
com.heytap.music
com.coloros.video
com.coloros.gallery3d
com.coloros.calculator
com.coloros.filemanager
com.android.mms
com.android.dialer
com.android.contacts
com.coloros.alarmclock
com.coloros.soundrecorder
com.oppo.camera

# --- Other Pre-installed or Tracking Apps ---
com.nearme.gamecenter
com.nearme.romupdate
com.nearme.statistics.rom
com.oppoex.afterservice
com.oplus.onetrace
com.oplus.crashbox
com.oppo.atlas
com.oppo.engineermode
com.oppo.operationManual
com.oppo.oppopowermonitor
com.oppo.multimedia.dirac
com.oppo.lfeh
com.heytap.browser
com.glance.internet
com.finshell.fin
com.coloros.apprecover
com.ted.number
com.realmecomm.app
com.os.docvault
com.realme.link
com.realmestore.app
com.coloros.onekeylockscreen
com.coloros.videoeditor
com.coloros.compass2
)

# Function to uninstall or disable a package
debloat_package() {
  local package_name="$1"

  echo "Attempting to uninstall $package_name..."
  adb -s "$DEVICE_SERIAL" shell pm uninstall -k --user 0 "$package_name"

  if [ $? -ne 0 ]; then
    echo "Uninstall failed. Attempting to disable $package_name..."
    adb -s "$DEVICE_SERIAL" shell pm disable-user --user 0 "$package_name"

    if [ $? -ne 0 ]; then
      echo "Disabling $package_name also failed. Please check ADB connection and root status."
    else
      echo "$package_name disabled successfully."
    fi
  else
    echo "$package_name uninstalled successfully."
  fi
}

# Check if adb is available
if ! command -v adb &> /dev/null; then
  echo "ADB could not be found. Please install ADB and add it to your PATH."
  exit 1
fi

# Verify device is connected
if ! adb devices | grep -q "$DEVICE_SERIAL.*device"; then
  echo "Device $DEVICE_SERIAL not found or not in 'device' state."
  adb devices
  exit 1
fi

# Loop through the packages and debloat them
for package in "${packages[@]}"; do
  debloat_package "$package"
done

echo "Debloating process complete on $DEVICE_SERIAL."
