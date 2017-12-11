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

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking, xTimeZone, xStorage, LanguageDsc

    Node $nodeName

    {
                xEnvironment CreatePathEnvironmentVariable
        {
            Name = "PLEXOS_TEMP"
            Ensure = "Present"
            Path = $True
            Value = "F:\TEMP"
            Target = @('Process', 'Machine')
        }

        		xFirewall PlexosLicense
		{
			Name = 'PlexosLicense-Port-In-TCP'
			Group = 'Web Server'
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
			Group = 'Web Server'
			Ensure = 'Present'
			Action = 'Allow'
			Enabled = 'True'
			Profile = 'Any'
			Direction = 'Inbound'
			Protocol = 'TCP'
			LocalPort = 8888
        }

        xTimeZone TimeZone
        
                {
        
                    IsSingleInstance = 'Yes'
                    TimeZone         = 'E. Australia Standard Time'
        
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
        
        xUser NewUser
        {
            UserName             = $Credential.UserName
            Password             = $Credential
            Disabled             = $false
            Ensure               = 'Present'
            PasswordNeverExpires = $true
        }

        xWaitforDisk Disk2
        
        {
            DiskNumber = 2            
            RetryIntervalSec = 60
            Count = 60        
        }
        
        xDisk FVolume
        
        {        
            DiskNumber = 2            
            DriveLetter = 'F'            
            FSLabel = 'Plexos'        
        }

        File PlexosFolder
        
        {        
             Ensure = 'Present'        
             Type = 'Directory'        
             DestinationPath = 'F:\Temp'
             DependsOn = "[xDisk]FVolume"        
        }
    }
}
