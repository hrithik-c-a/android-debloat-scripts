#!/bin/bash

# Target Device Selection
DEVICE_SERIAL="$1"
if [ -z "$DEVICE_SERIAL" ]; then
  DEVICE_SERIAL=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')
fi

if [ -z "$DEVICE_SERIAL" ]; then
  echo "No device connected. Check ADB."
  exit 1
fi

packages=(
  # --- 1. DE-GOOGLE (Tracking & Bloat) ---
  com.android.chrome                       # Chrome
  com.google.android.youtube               # YouTube
  com.google.android.apps.docs             # Drive
  com.google.android.apps.maps             # Maps
  com.google.android.apps.photos           # Photos
  com.google.android.googlequicksearchbox  # Google App
  com.google.android.gm                    # Gmail
  com.google.android.apps.tachyon          # Duo/Meet
  com.google.android.videos                # Google TV
  com.google.android.music                 # YT Music
  com.google.android.apps.magazines        # Google News
  com.google.android.apps.wellbeing        # Digital Wellbeing
  com.google.android.apps.messaging        # Google Messages
  com.google.android.contacts              # Google Contacts
  com.android.vending                      # Play Store
  com.google.android.feedback              # Feedback tracking
  com.google.android.gms.location.history  # Location History Tracking
  
  # --- 2. SAMSUNG ACCOUNT, CLOUD & PASS ---
  com.osp.app.signin                       # Samsung Account (SIGN OUT FIRST)
  com.samsung.android.scloud               # Samsung Cloud
  com.samsung.android.samsungpass          # Samsung Pass
  com.samsung.android.samsungpassautofill  # Samsung Pass Auto-fill
  com.samsung.android.authfw               # Authentication Framework
  com.samsung.android.app.spage            # Samsung Free / Daily
  
  # --- 3. BIXBY & ROUTINES ---
  com.samsung.android.app.routines         # Bixby Routines / Modes
  com.samsung.android.bixby.agent          # Bixby Voice
  com.samsung.android.bixby.wakeup         # Bixby Wakeup
  com.samsung.android.bixby.service        # Bixby Service
  com.samsung.android.visionintelligence   # Bixby Vision
  com.samsung.android.bixbyvision.framework
  
  # --- 4. BLOATWARE & AD PLATFORMS ---
  com.sec.android.app.samsungapps          # Galaxy Store
  com.samsung.android.app.tips             # Tips
  com.samsung.android.kidsinstaller        # Samsung Kids
  com.samsung.android.app.watchmanagerstub # Galaxy Wearable
  com.samsung.android.dynamiclock          # Glance / Dynamic Lockscreen
  com.aura.oobe.samsung.gl                 # App Cloud (Pre-install ads)
  com.aura.oobe.samsung                    # App Cloud Alternative
  com.ironsource.appcloud.oobe             # App Cloud Framework
  
  # --- 5. AR & GALAXY FRIENDS ---
  com.samsung.android.arzone               # AR Zone
  com.samsung.android.aremoji              # AR Emoji
  com.samsung.android.aremojieditor        # AR Emoji Editor
  com.samsung.android.arcanvas             # AR Canvas
  com.samsung.android.livestickers         # Live Stickers
  com.samsung.android.mateagent            # Galaxy Friends
  
  # --- 6. LINK TO WINDOWS ---
  com.microsoft.appmanager                 # Link to Windows Service
  com.samsung.android.mdx                  # Link to Windows (Connectivity)
  com.samsung.android.mdx.kit              # Link to Windows Framework
  
  # --- 7. KEYBOARD CONTENT & SMART CLIP ---
  com.samsung.android.honeyboard.overlay.cpp # Keyboard Content Provider
  com.samsung.android.smartclip.collector    # Analytics/Content tracking
  
  # --- 8. GAMING & TELEMETRY ---
  com.samsung.android.game.gamehome        # Game Launcher
  com.samsung.android.game.gametools       # Game Tools
  com.samsung.android.game.gos             # Game Optimizing Service
  com.samsung.android.securitylogagent     # Security Log (Tracking)
  com.samsung.android.da.daagent           # Data Analysis Agent
  com.samsung.android.ipsgeofence          # Geo-fencing tracking
  com.samsung.android.mdecservice          # Call/Text on other devices
  
  # --- 9. FACEBOOK & MICROSOFT ---
  com.facebook.katana
  com.facebook.system
  com.facebook.appmanager
  com.facebook.services
  com.microsoft.skydrive                   # OneDrive
  com.microsoft.office.officehubrow        # Office
)

debloat_package() {
  local pkg="$1"
  echo -n "Cleaning $pkg... "
  adb -s "$DEVICE_SERIAL" shell pm uninstall -k --user 0 "$pkg" > /dev/null 2>&1
  if [ $? -eq 0 ]; then echo "DONE"; else echo "ALREADY GONE/FAIL"; fi
}

echo "Starting Deep Clean on $DEVICE_SERIAL..."
for package in "${packages[@]}"; do
  debloat_package "$package"
done

echo "------------------------------------------------"
echo "Script complete. Please restart your Galaxy A50."