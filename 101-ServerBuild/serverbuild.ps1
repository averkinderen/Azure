# Script to define regional settings on Azure Virtual Machines deployed from the market place
#
# Blogpost: 
#
######################################33

#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/averkinderen/Azure/master/101-ServerBuild/AURegion.xml"
$RegionalSettings = "D:\AURegion.xml"


#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)


# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU -Force
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12
Set-TimeZone -Name "E. Australia Standard Time"

# restart virtual machine to apply regional settings to current user.
Start-sleep -Seconds 40
Restart-Computer