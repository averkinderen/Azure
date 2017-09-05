Write-Host "Hello World!"
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU -Force
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12
[Environment]::SetEnvironmentVariable("PLEXOS_TEMP", "P:\Temp", "Machine")
Set-TimeZone -Name "AUS Eastern Standard Time"