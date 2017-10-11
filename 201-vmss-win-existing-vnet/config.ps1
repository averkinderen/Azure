#region Set the parameters
$WorkSpaceID = "e78d0e2a-cd07-4002-ae97-9524397945e2"
$WorkSpaceKey = "x6GrE84EHrxAJGlUQuk5E56FTZfGUNk43fP3uJHnRWP5S8XEhwgt+ZMbv6/u4SRWw1jcdhs6ylomalzXwV+GpA=="
$FileName = "MMASetup-AMD64.exe" 
$OMSFolder = 'C:\Source' 
$MMAFile = $OMSFolder + "\" + $FileName 
$machine = hostname
$name = $machine.Substring($machine.Length - 6)
$drive = get-volume -FileSystemLabel 'Plexos Data'
$plexos = $drive.DriveLetter + ':\Temp'
$plexoskeyfolder = 'C:\Users\marketsims\AppData\Roaming\PLEXOS'
$plexosxmlfile = $plexoskeyfolder + '\PLEXOS Connect Client.xml'
$clientfile = $plexos + '\clientutil.zip'
$url = "https://raw.githubusercontent.com/averkinderen/Azure/master/201-vmss-win-existing-vnet/xml/" + $name + ".xml"
$clientutilurl = "https://github.com/averkinderen/Azure/raw/master/201-vmss-win-existing-vnet/scripts/clientutil.zip"
#endregion

#start script
Stop-Service "PLEXOS Connect Client Service"
Set-WinSystemLocale en-AU
Set-WinUserLanguageList -LanguageList en-AU -Force
Set-Culture -CultureInfo en-AU
Set-WinHomeLocation -GeoId 12
Set-TimeZone -Name "E. Australia Standard Time"

#get volume and set variables
[Environment]::SetEnvironmentVariable("PLEXOS_TEMP", $plexos, "Machine")
[Environment]::SetEnvironmentVariable("MAX_FILE_AGE", "1", "Machine")

#downdload files
$webclient = New-Object System.Net.WebClient
#$webclient.DownloadFile($url,$plexosxmlfile)
$webclient.DownloadFile($clientutilurl,$clientfile)

#EXTRACT ZIP
$shell = New-Object -ComObject shell.application
$zip = $shell.NameSpace("$clientfile")
foreach ($item in $zip.items()) {
  $shell.Namespace("$plexos").CopyHere($item)
}

#RUN CLIENT

Set-Location -Path $plexos
.\connect.client.exe --server "10.0.1.4" --port "8888" --name $machine --username "marketsims" --password "M@rket%^TYghbn" --worker-count 13 --export-config "C:\Users\marketsims\AppData\Roaming\PLEXOS\PLEXOS Connect Client.xml"
Start-Service "PLEXOS Connect Client Service"

#OMS
# Check if folder exists, if not, create it 
 if (Test-Path $OMSFolder){ 
  
 }  
 else  
 { 
 New-Item $OMSFolder -type Directory | Out-Null 
 } 
 
# Change the location to the specified folder 
Set-Location $OMSFolder 
 
# Check if file exists, if not, download it 
 if (Test-Path $FileName){ 
  
 } 
 else 
 { 
 $URL = "http://download.microsoft.com/download/1/5/E/15E274B9-F9E2-42AE-86EC-AC988F7631A0/MMASetup-AMD64.exe" 
 Invoke-WebRequest -Uri $URl -OutFile $MMAFile | Out-Null 
 } 
  
# Install the agent 
$ArgumentList = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 '+  "OPINSIGHTS_WORKSPACE_ID=$WorkspaceID " + "OPINSIGHTS_WORKSPACE_KEY=$WorkSpaceKey " +'AcceptEndUserLicenseAgreement=1"' 
Start-Process $FileName -ArgumentList $ArgumentList -ErrorAction Stop -Wait | Out-Null
