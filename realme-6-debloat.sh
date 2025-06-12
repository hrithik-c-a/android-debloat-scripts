#!/bin/bash

# List of packages to debloat
packages=(

# --- Google Apps to remove ---
com.google.android.youtube
com.google.android.gm
com.android.chrome
com.google.android.apps.translate
com.google.android.apps.docs
com.google.android.apps.photos   # You said you want to keep Photos; ensure this refers to Google Photos, not Gallery
com.google.android.apps.maps
com.google.android.keep
com.google.android.apps.nbu.paisa.user
com.google.android.apps.wellbeing
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
com.google.android.calendar       # <- Added now
com.android.vending       

# --- Facebook Pre-installs ---
com.facebook.app
com.facebook.services
com.facebook.appmanager
com.facebook.system

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
com.coloros.sau
com.coloros.smartdrive
com.coloros.deepthinker
com.coloros.backuprestore
com.coloros.wallpapers
com.coloros.translate.engine
com.coloros.karaoke
com.coloros.healthcheck
com.coloros.uxdesign
com.coloros.lockassistant
com.coloros.simsettings
com.coloros.eyeprotect
com.coloros.ocs.opencapabilityservice
com.coloros.encryption
com.coloros.athena

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

# Optional/Harmless (commented out for safety)
# com.android.egg           # Android Easter egg
# com.android.fmradio       # Keep if you use FM Radio
# com.google.android.setupwizard  # KEEP unless using de-Googled ROM
# com.google.android.apps.restore # Optional backup tool
)

# Function to uninstall or disable a package
debloat_package() {
  local package_name="$1"

  echo "Attempting to uninstall $package_name..."

  adb shell pm uninstall -k --user 0 "$package_name"

  if [ $? -ne 0 ]; then
    echo "Uninstall failed. Attempting to disable $package_name..."

    adb shell pm disable-user --user 0 "$package_name"

    if [ $? -ne 0 ]; then
      echo "Disabling $package_name also failed. Please check adb connection and root status."
    else
      echo "$package_name disabled successfully."
    fi
  else
    echo "$package_name uninstalled successfully."
  fi
}

# Check if adb is available
if ! command -v adb &> /dev/null; then
  echo "adb could not be found. Please install adb and add it to your PATH."
  exit 1
fi

# Check if a device is connected
if [ -z "$(adb devices | grep -w device | awk '{print $1}')" ]; then
    echo "No device connected. Connect your device and enable USB debugging."
    exit 1
fi

# Loop through the packages and debloat them
for package in "${packages[@]}"; do
  debloat_package "$package"
done

echo "Debloating process complete."
