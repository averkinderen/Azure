configuration TestLab
{
    param
    (
        [string[]]$NodeName ='localhost',
        [Parameter(Mandatory)][string]$MachineName,
        [Parameter(Mandatory)][string]$WorkGroupName,
        [Parameter()][string]$UserName,
        [Parameter()]$Password
    ) 
 
    #Import the required DSC Resources

 
    Node $NodeName
    {
 
        User LocalAdmin {
            UserName = $UserName
            Description = 'Our new local admin'
            Ensure = 'Present'
            FullName = 'Stephen FoxDeploy'
            Password = $Password
            PasswordChangeRequired = $false
            PasswordNeverExpires = $true
        }
 
    }
}
 
$configData = 'a'
 
$configData = @{
                AllNodes = @(
                              @{
                                 NodeName = 'localhost';
                                 PSDscAllowPlainTextPassword = $true
                                    }
                    )
               }
 
#See whats needs to be configured
# Get-DscResource User | select -ExpandProperty Properties | select -expand name
 
TestLab -MachineName localhost -WorkGroupName WORKGROUP -Password (Get-Credential -UserName 'FoxDeploy' -Message 'Enter New Password') -UserName 'FoxDeploy' -ConfigurationData $configData
 
Start-DscConfiguration -ComputerName localhost -Wait -Force -Verbose -path .\TestLab.ps1