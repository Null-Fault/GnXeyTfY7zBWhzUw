[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Apps = @()
$Required = @(
    'Microsoft.VC++2015-2022Redist-x64'
    'Google.Chrome'
    'Microsoft.PowerShell'
    'Git.Git'
    'Microsoft.VisualStudioCode'
    '7zip.7zip'
    'Microsoft.RemoteDesktopClient'
    'KeePassXCTeam.KeePassXC'
)
$Apps += $Required

$Optional = @(
    'VideoLAN.VLC'
    'Valve.Steam'
    'Parsec.Parsec'
    'Nvidia.GeForceNow'
)
$Apps += $Optional

$HasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$HasPackageManager -or [version]$HasPackageManager.Version -lt [version]"1.10.0.0") {
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $ReleasesUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    $Releases = Invoke-RestMethod -Uri $ReleasesUrl
    $LatestRelease = $Releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1

    Add-AppxPackage -Path $LatestRelease.browser_download_url
}

$SettingsPath = Resolve-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$SettingsJson = @"
{
    "$schema": "https://aka.ms/winget-settings.schema.json",

    // For documentation on these settings, see: https://aka.ms/winget-settings
    // "source": {
    //    "autoUpdateIntervalInMinutes": 5
    // },
    "telemetry": {
        "disable": true
    },

    "installBehavior": {
        "preferences": {
            "scope": "machine",
            "architectures": ["x64"]
        }
    }
}
"@
$SettingsJson | Out-File -FilePath $SettingsPath -Force -Encoding utf8

$WinGetPath = Resolve-Path -Path "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\winget.exe"
$WinGetPath = $WinGetPath.Path
foreach ($App in $Apps) {
    $AppArg = "install -e --id $App --accept-package-agreements --accept-source-agreements"
    Start-Process -FilePath $WinGetPath -ArgumentList $AppArg -Wait
}
