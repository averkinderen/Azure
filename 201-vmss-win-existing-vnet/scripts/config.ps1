Stop-Service "PLEXOS Connect Client Service"
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU -Force
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12
Set-TimeZone -Name "E. Australia Standard Time"

$drive = get-volume -FileSystemLabel 'Plexos Data'
$plexos = $drive.DriveLetter + ':\Temp'
[Environment]::SetEnvironmentVariable("PLEXOS_TEMP", $plexos, "Machine")


$machine = hostname
$name = $machine.Substring($machine.Length - 6)
$plexoskeyfolder = 'C:\Users\marketsims\AppData\Roaming\PLEXOS'
$plexosxmlfile = $plexoskeyfolder + '\PLEXOS Connect Client.xml'
$webclient = New-Object System.Net.WebClient
$url = "https://raw.githubusercontent.com/averkinderen/Azure/master/201-vmss-win-existing-vnet/xml/" + $name + ".xml"
$webclient.DownloadFile($url,$plexosxmlfile)

Start-Service "PLEXOS Connect Client Service"