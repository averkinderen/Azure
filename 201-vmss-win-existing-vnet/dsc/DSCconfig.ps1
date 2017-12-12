Configuration Main
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]
        $nodeName
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking, xTimeZone, LanguageDsc, xPendingReboot, xStorage, SecurityPolicyDsc

    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $false
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
        }
        
        xFirewall PlexosLicense
		{
			Name = 'PlexosLicense-Port-In-TCP'
			Group = 'Plexos'
			Ensure = 'Present'
			Action = 'Allow'
			Enabled = 'True'
			Profile = 'Any'
			Direction = 'Inbound'
			Protocol = 'TCP'
			LocalPort = 399
        }
        
        xFirewall PlexosConnect
		{
			Name = 'PlexosConnect-Port-In-TCP'
			Group = 'Plexos'
			Ensure = 'Present'
			Action = 'Allow'
			Enabled = 'True'
			Profile = 'Any'
			Direction = 'Inbound'
			Protocol = 'TCP'
			LocalPort = 8888
        }

        xUser NewUser
        {
            UserName             = $Credential.UserName
            Password             = $Credential
            Disabled             = $false
            Ensure               = 'Present'
            PasswordNeverExpires = $true
        }

        Group GroupSet
        {
            GroupName = 'Administrators'
            Ensure = 'Present'
            MembersToInclude = $Credential.UserName
            DependsOn = "[xUser]NewUser"
        }

        UserRightsAssignment LogonAsaService
        {            
            Policy = "Log_on_as_a_service"
            Identity = "Builtin\Administrators"
            DependsOn = "[Group]GroupSet"
        }

        xTimeZone TimeZone        
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'E. Australia Standard Time'        
        }

        xWaitforDisk Disk2        
        {
            DiskId = 2            
            RetryIntervalSec = 20
            RetryCount = 30        
        }
        
        xDisk ADDataDisk {
            DiskId = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        File PlexosFolder
        {        
             Ensure = 'Present'        
             Type = 'Directory'        
             DestinationPath = 'F:\Temp'
             DependsOn = "[xDisk]ADDataDisk"        
        }

        xEnvironment CreatePathEnvironmentVariable
        {
            Name = "PLEXOS_TEMP"
            Ensure = "Present"
            Path = $True
            Value = "F:\TEMP"
            Target = @('Process', 'Machine')
            DependsOn = "[File]PlexosFolder"
        }

        xRemoteFile ConnectMSI
        {
            Uri = 'https://azrrmtpasasta01.blob.core.windows.net/mtpasa/PLEXOS.Connect.Client.3.00R01.msi'
            DestinationPath = 'F:\TEMP\PLEXOS.Connect.Client.3.00R01.msi'
            DependsOn = "[File]PlexosFolder"
        }

        Package ConnectClient
        {
        Ensure      = "Present"
        Path        = "F:\TEMP\PLEXOS.Connect.Client.3.00R01.msi"
        Name        = "PLEXOS Connect Client"
        ProductId   = "6603B46E-B758-4255-9006-3CB4F273672D"
        DependsOn = "[xRemoteFile]ConnectMSI"
        } 

        Language ConfigureLanguage 
        {
            IsSingleInstance = "Yes" 
            LocationID = 12 
            MUILanguage = "en-AU" 
            MUIFallbackLanguage = "en-US"
            SystemLocale = "en-AU" 
            AddInputLanguages = @("0c09:00000409") 
            RemoveInputLanguages = @("0409:00000409")
            UserLocale = "en-AU"
            CopySystem = $true 
            CopyNewUser = $true
        }

        xPendingReboot Reboot
        { 
            Name = 'reboot'
             DependsOn = "[Package]ConnectClient"
        }

    }
}