try {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$Apps = @()
	$Required = @(
		'Microsoft.VCRedist.2015+.x64'
		'Mozilla.Firefox'
		'Google.Chrome' # V3 Manifest sucks. Chrome sucks.
		'Microsoft.PowerShell'
		'Git.Git'
		'Microsoft.VisualStudioCode'
		'7zip.7zip' # 7zip reintsalls everytime. I don't care. Comment out if you care.
		'Microsoft.RemoteDesktopClient'
		'KeePassXCTeam.KeePassXC'
	)
	$Apps += $Required

	$Optional = @(
		'VideoLAN.VLC'
		'Valve.Steam'
		'Parsec.Parsec'
		'Nvidia.GeForceNow'
		'RedHat.VirtViewer'
		'Telerik.Fiddler.Classic'
	)
	$Apps += $Optional # Comment out if not needed. Add a selection function... sometime.

	$Packages = @()
	foreach ($App in $Apps) {
		$Packages += @{PackageIdentifier = $App }
	}

	$WingetExport = [PSCustomObject]@{ # There's no reason to do this except to play with PSCustomObjects
		'$schema'     = "https://aka.ms/winget-packages.schema.2.0.json"
		CreationDate  = "2022-08-01T00:00:00.000-00:00"
		Sources       = @(@{
				Packages      = @($Packages)
				SourceDetails = @{
					Argument   = "https://cdn.winget.microsoft.com/cache"
					Identifier = "Microsoft.Winget.Source_8wekyb3d8bbwe"
					Name       = "winget"
					Type       = "Microsoft.PreIndexed.Package"
				}
			})
		WinGetVersion = "1.3.2091"
	}
	$WingetExport = $WingetExport | ConvertTo-Json -Depth 100

	$TempFile = New-TemporaryFile 
	$TempFile = Rename-Item -Path $TempFile -NewName "$(New-Guid).json" -PassThru
	$WingetExport | Out-File -FilePath $TempFile -Encoding utf8
	
	$HasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
	if (!$HasPackageManager -or [version]$HasPackageManager.Version -lt [version]"1.10.0.0") {
		Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

		$ReleasesUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

		$Releases = Invoke-RestMethod -Uri $ReleasesUrl
		$LatestRelease = $Releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1

		Add-AppxPackage -Path $LatestRelease.browser_download_url
	}
	$SettingsPath = Convert-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
	
	$SettingsJson = [PSCustomObject]@{ # There's no reason to do this except to play with PSCustomObjects
		'$schema'       = "https://aka.ms/winget-settings.schema.json"
		telemetry       = @{
			disable = $true
		}
		installBehavior = @{
			preferences = @{
				scope         = "machine"
				architectures = @("x64")
			}
		}
	}
	$SettingsJson = $SettingsJson | ConvertTo-Json -Depth 10
	$SettingsJson | Out-File -FilePath $SettingsPath -Force -Encoding utf8
	$WinGetPath = Convert-Path -Path "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\winget.exe"
	$TempFilePath = $TempFile.ToString() # Get the path
	Start-Process -FilePath $WinGetPath -ArgumentList "import -i $TempFilePath" -Wait
} catch {
	$Err = $_
	Write-Host $Err.Exception.GetType().FullName
	throw $Err
} finally {
	if (Test-Path -Path $TempFile) {
		Remove-Item -Path $TempFile
	}
}
