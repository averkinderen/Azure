Stop-Service "PLEXOS Connect Client Service"
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU -Force
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12

$drive = get-volume -FileSystemLabel 'Plexos Data'
$plexos = $drive.DriveLetter + ':\temp'
[Environment]::SetEnvironmentVariable("PLEXOS_TEMP", $plexos, "Machine")
Set-TimeZone -Name "AUS Eastern Standard Time"
Start-Service "PLEXOS Connect Client Service"