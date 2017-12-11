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

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking, xTimeZone, SystemLocaleDsc

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

        SystemLocale Australia
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = 'en-AU'
        }
        
        xUser NewUser
        {
            UserName             = $Credential.UserName
            Password             = $Credential
            Disabled             = $false
            Ensure               = 'Present'
            PasswordNeverExpires = $true
        }
    }
}
