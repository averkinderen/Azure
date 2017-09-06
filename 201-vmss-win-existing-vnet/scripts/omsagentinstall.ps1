<# 
Author:      Daniel Örneling 
Date:        28/12/2016 
Script:      InstallOMSAgent.ps1 
Version:     1.0 
Twitter:     @DanielOrneling 
#> 
 
# Set the Workspace ID and Primary Key for the Log Analytics workspace. 
[CmdletBinding(SupportsShouldProcess=$true)] 

 
# Set the parameters
$WorkSpaceID = "e78d0e2a-cd07-4002-ae97-9524397945e2"
$WorkSpaceKey = "x6GrE84EHrxAJGlUQuk5E56FTZfGUNk43fP3uJHnRWP5S8XEhwgt+ZMbv6/u4SRWw1jcdhs6ylomalzXwV+GpA=="

$FileName = "MMASetup-AMD64.exe" 
$OMSFolder = 'C:\Source' 
$MMAFile = $OMSFolder + "\" + $FileName 
 
# Start logging the actions 
Start-Transcript -Path C:\OMSAgentInstallLog.txt -NoClobber 
 
# Check if folder exists, if not, create it 
 if (Test-Path $OMSFolder){ 
 Write-Host "The folder $OMSFolder already exists." 
 }  
 else  
 { 
 Write-Host "The folder $OMSFolder does not exist, creating..." -NoNewline 
 New-Item $OMSFolder -type Directory | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 } 
 
# Change the location to the specified folder 
Set-Location $OMSFolder 
 
# Check if file exists, if not, download it 
 if (Test-Path $FileName){ 
 Write-Host "The file $FileName already exists." 
 } 
 else 
 { 
 Write-Host "The file $FileName does not exist, downloading..." -NoNewline 
 $URL = "http://download.microsoft.com/download/1/5/E/15E274B9-F9E2-42AE-86EC-AC988F7631A0/MMASetup-AMD64.exe" 
 Invoke-WebRequest -Uri $URl -OutFile $MMAFile | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 } 
  
# Install the agent 
Write-Host "Installing Microsoft Monitoring Agent.." -nonewline 
$ArgumentList = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 '+  "OPINSIGHTS_WORKSPACE_ID=$WorkspaceID " + "OPINSIGHTS_WORKSPACE_KEY=$WorkSpaceKey " +'AcceptEndUserLicenseAgreement=1"' 
Start-Process $FileName -ArgumentList $ArgumentList -ErrorAction Stop -Wait | Out-Null 
Write-Host "done!" -ForegroundColor Green 
 
# Change the location to C: to remove the created folder 
Set-Location -Path "C:\" 
 
<# 
# Remove the folder with the agent 
 if (-not (Test-Path $OMSFolder)) { 
 Write-Host "The folder $OMSFolder does not exist." 
 }  
 else  
 { 
 Write-Host "Removing the folder $OMSFolder ..." -NoNewline 
 Remove-Item $OMSFolder -Force -Recurse | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 } 
#> 
 
Stop-Transcript