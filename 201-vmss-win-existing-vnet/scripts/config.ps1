Write-Host "Hello World!"
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12
[Environment]::SetEnvironmentVariable("PLEXOS_TEMP", "My Value", "P:\Temp")