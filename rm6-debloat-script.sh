#!/bin/bash

# Usage:
#   ./rm6-debloat-script.sh ZHLJJNVGAYHUP7QC
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

# --- CRITICAL GOOGLE APPS (To be KEPT: Webview and GMS) ---
# DO NOT REMOVE:
# com.google.android.webview # Webview - REQUIRED FOR MANY APPS TO RENDER WEB CONTENT
# com.google.android.gms # Google Play Services - REQUIRED FOR BASIC FUNCTIONALITY/NOTIFICATIONS
com.android.vending # Playstore - REMOVING: Using Aurora Store for app downloads
# com.coloros.uxdesign # Night Light Scheduling
# com.coloros.eyeprotect # Eye Comfort Mode
# com.coloros.systemservice # KEEP: Essential OS component

# --- AOSP/ColorOS Core Apps (TO BE KEPT for basic device functionality) ---
# The following core apps are commented out to keep them functional:
# com.android.dialer # Phone
# com.android.contacts # Contacts
# com.android.mms # Messages (AOSP)
# com.oppo.camera # Default Camera App
# com.coloros.alarmclock # Clock/Alarm
# com.coloros.calculator # Calculator
# com.coloros.compass2 # Compass
# com.coloros.filemanager # File Manager
# com.coloros.soundrecorder # Sound Recorder
# com.coloros.gallery3d # Photos/Gallery
# com.heytap.music # Music Player
# com.coloros.video # Video Player

# --- Non-Essential AOSP/System Apps (Safe to remove) ---
com.android.fmradio

# --- Google Bloatware (To be removed for de-googled setup) ---
com.google.android.dialer # Google Phone App (Removing, keeping AOSP/ColorOS)
com.google.android.contacts # Google Contacts App (Removing, keeping AOSP/ColorOS)
com.google.android.apps.messaging # Google Messages App
com.google.android.gm # Gmail
com.google.android.deskclock # Google Clock (Removing, keeping ColorOS)
com.google.android.calculator # Google Calculator (Removing, keeping ColorOS)
com.google.android.inputmethod.latin # Gboard
com.google.android.apps.photosgo # Gallery Go
com.google.android.apps.photos # Google Photos (Removing, keeping ColorOS Gallery)
com.google.android.apps.nbu.files # Files by Google
com.google.android.apps.maps # Maps
com.google.android.apps.wellbeing # Digital Well-being
com.google.android.marvin.talkback # Talkback
com.google.android.accessibility.soundamplifier # Sound Amplifier
com.google.android.youtube
com.android.chrome
com.google.android.apps.docs
com.google.ar.lens
com.google.android.keep # Keep Notes
com.google.android.apps.nbu.paisa.user # Google Pay/Wallet (Tez)
com.google.android.apps.tachyon # Google Duo/Meet
com.google.android.apps.youtube.music
com.google.android.apps.meetings
com.google.android.videos # Google TV (Play Movies)
com.google.android.projection.gearhead # Android Auto
com.google.android.apps.podcasts
com.google.android.apps.magazines # Google News
com.google.android.music # YouTube Music/Play Music
com.google.android.feedback # Google Feedback/Bug Reporting
com.google.android.googlequicksearchbox # Google Search App/Widget
com.google.android.calendar
com.google.android.apps.translate
com.google.ar.core # Google AR Core

# --- Facebook Pre-installs / Tracking ---
com.facebook.app
com.facebook.services
com.facebook.appmanager
com.facebook.system
com.facebook.katana

# --- Realme / HeyTap / ColorOS Bloatware & Telemetry ---
com.heytap.cloud # HeyTap Cloud
com.heytap.market # App Market
com.heytap.themestore # Themes Store
com.heytap.openid
com.heytap.pictorial # Lock Screen Magazine
com.heytap.usercenter
com.coloros.childrenspace # Kids Space
com.coloros.smartsidebar # Smart Sidebar
com.coloros.focusmode # Focus Mode
com.coloros.gamespace # Game Space
com.coloros.assistantscreen # Smart Assistant/Google Feed replacement
com.coloros.sceneservice
com.coloros.securitycheck
com.coloros.screenrecorder
com.coloros.systemclone
com.coloros.oppomultiapp
com.coloros.sauhelper # System Update Helper
com.coloros.logkit # Logging/Debugging Tool
com.coloros.sau # System Update
com.coloros.smartdrive
com.coloros.deepthinker # AI/Machine Learning
com.coloros.backuprestore
com.coloros.wallpapers
com.coloros.translate.engine
com.coloros.karaoke
com.coloros.healthcheck
com.coloros.lockassistant
com.coloros.simsettings
com.coloros.ocs.opencapabilityservice
com.coloros.encryption
com.coloros.athena # Personalization/Deepthinker service
com.coloros.oshare # OShare/File Sharing
com.coloros.phonemanager # Security/Optimizer
com.coloros.onekeylockscreen
com.coloros.videoeditor
com.coloros.weather2 # Weather App

# --- Additional Community-Vetted Bloatware/Tracking Apps ---
com.nearme.gamecenter
com.nearme.romupdate
com.nearme.statistics.rom # Telemetry/Statistics
com.oppoex.afterservice
com.oplus.onetrace # Telemetry/Tracing
com.oplus.crashbox # Crash Reporting
com.oppo.atlas # Telemetry/Diagnostics
com.oppo.engineermode # Engineer Mode
com.oppo.operationManual # Operation Manual/User Guide
com.oppo.oppopowermonitor
com.oppo.multimedia.dirac # Dirac Audio Enhancement
com.oppo.lfeh
com.heytap.browser
com.glance.internet # Glance Lockscreen
com.finshell.fin
com.coloros.apprecover
com.ted.number # Ted (India specific bloat)
com.realmecomm.app
com.os.docvault # DocVault
com.realme.link # Realme Link
com.realmestore.app # Realme Store
com.redteamobile.roaming # Roaming Service
com.coloros.romupdate # ROM Update / System Update service
com.coloros.activation # Device Activation
com.coloros.securityguard # Security Guard/Antivirus
com.coloros.finddevice # Find My Device service

)

# Function to uninstall or disable a package
debloat_package() {
    local package_name="$1"

    echo "Attempting to uninstall $package_name..."
    # Use --user 0 to uninstall for the current user (safe, non-root)
    adb -s "$DEVICE_SERIAL" shell pm uninstall -k --user 0 "$package_name"

    # Check the return code of the last command
    if [ $? -ne 0 ]; then
        echo "Uninstall failed. Attempting to disable $package_name..."
        # Use pm disable-user to disable for the current user
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
