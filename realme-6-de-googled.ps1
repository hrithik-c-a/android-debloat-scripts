# List of packages to debloat
$packages = @(
    # --- Google Apps to remove ---
    'com.google.android.inputmethod.latin',
    'com.google.android.gms',
    'com.android.vending',
    'com.google.android.youtube',
    'com.google.android.gm',
    'com.android.chrome',
    'com.google.android.apps.translate',
    'com.google.android.apps.docs',
    'com.google.android.apps.photos',
    'com.google.android.apps.maps',
    'com.google.android.keep',
    'com.google.android.apps.nbu.paisa.user',
    #'com.google.android.apps.wellbeing',
    'com.google.android.apps.tachyon',
    'com.google.android.apps.youtube.music',
    'com.google.android.apps.meetings',
    'com.google.android.videos',
    'com.google.android.projection.gearhead',
    'com.google.android.apps.podcasts',
    'com.google.android.apps.magazines',
    'com.google.android.music',
    'com.google.android.feedback',
    'com.google.android.googlequicksearchbox',
    'com.google.android.calendar',

    # --- Facebook Pre-installs ---
    'com.facebook.app',
    'com.facebook.services',
    'com.facebook.appmanager',
    'com.facebook.system',

    # --- Realme / HeyTap / ColorOS Bloatware ---
    'com.heytap.music',
    'com.coloros.video',
    'com.heytap.cloud',
    'com.heytap.market',
    'com.heytap.themestore',
    'com.heytap.openid',
    'com.heytap.pictorial',
    'com.heytap.usercenter',
    'com.coloros.childrenspace',
    'com.coloros.smartsidebar',
    'com.coloros.focusmode',
    'com.coloros.gamespace',
    'com.coloros.assistantscreen',
    'com.coloros.sceneservice',
    'com.coloros.securitycheck',
    'com.coloros.screenrecorder',
    'com.coloros.systemclone',
    'com.coloros.oppomultiapp',
    'com.coloros.sauhelper',
    'com.coloros.sau',
    'com.coloros.smartdrive',
    'com.coloros.deepthinker',
    'com.coloros.backuprestore',
    'com.coloros.wallpapers',
    'com.coloros.translate.engine',
    'com.coloros.karaoke',
    'com.coloros.healthcheck',
    'com.coloros.uxdesign',
    'com.coloros.lockassistant',
    'com.coloros.simsettings',
    'com.coloros.eyeprotect',
    'com.coloros.ocs.opencapabilityservice',
    'com.coloros.encryption',
    'com.coloros.athena',	

    # --- Other Pre-installed or Tracking Apps ---
    'com.nearme.gamecenter',
    'com.nearme.romupdate',
    'com.nearme.statistics.rom',
    'com.oppoex.afterservice',
    'com.oplus.onetrace',
    'com.oplus.crashbox',
    'com.oppo.atlas',
    'com.oppo.engineermode',
    'com.oppo.operationManual',
    'com.oppo.oppopowermonitor',
    'com.oppo.multimedia.dirac',
    'com.oppo.lfeh',
    'com.heytap.browser',
    'com.glance.internet',
    'com.finshell.fin',
    'com.coloros.apprecover',
    'com.ted.number',
    'com.android.fmradio'
)

# Full path to adb.exe (update this path if needed)
$adbPath = "C:\Users\hrith\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"

function Execute-AdbCommand {
    param ([string[]]$command)
    try {
        # If first element is "adb" or "adb.exe", replace with full path
        if ($command[0] -match "adb(\.exe)?") {
            $exe = $adbPath
        }
        else {
            $exe = $command[0]
        }

        # Arguments are all elements after first
        $args = $command[1..($command.Length - 1)]

        Write-Host "Running: $exe $($args -join ' ')"

        # Run command with call operator
        $result = & "$exe" @args

        return $result
    }
    catch {
        Write-Host "Failed to run command: $($command -join ' '). Error: $_"
        return $null
    }
}


# Function to uninstall or disable a package
function Debloat-Package {
    param ([string]$packageName)
    Write-Host "Attempting to uninstall $packageName..."
    $uninstallCommand = "adb.exe", "shell", "pm", "uninstall", "-k", "--user", "0", $packageName
    $result = Execute-AdbCommand -command $uninstallCommand

    if ($result -and $result -match "Success") {
        Write-Host "$packageName uninstalled successfully."
    } else {
        Write-Host "Uninstall failed. Attempting to disable $packageName..."
        $disableCommand = "adb.exe", "shell", "pm", "disable-user", "--user", "0", $packageName
        $result = Execute-AdbCommand -command $disableCommand
        if ($result -and $result -match "Success") {
            Write-Host "$packageName disabled successfully."
        } else {
            Write-Host "Disabling $packageName also failed. Skipping $packageName."
        }
    }
}

# Check if adb is available
function Check-AdbAvailability {
    $versionCommand = "adb.exe", "--version"
    $result = Execute-AdbCommand -command $versionCommand
    if (-not $result) {
        Write-Host "adb could not be found. Please install adb and add it to your PATH or update the script with correct adb path."
        exit 1
    }
}

# Check if a device is connected
function Check-DeviceConnection {
    $devices = Execute-AdbCommand -command "adb.exe", "devices"
    if (-not $devices -or $devices -notmatch "device") {
        Write-Host "No device connected. Connect your device and enable USB debugging."
        exit 1
    }
}

function Main {
    Check-AdbAvailability
    Check-DeviceConnection

    foreach ($package in $packages) {
        Debloat-Package -packageName $package
    }

    Write-Host "Debloating process complete."
}

Main
