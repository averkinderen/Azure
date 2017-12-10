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

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking, xTimeZone

    Node $nodeName

    {
                xEnvironment CreatePathEnvironmentVariable
        {
            Name = "DSCTest"
            Ensure = "Present"
            Path = $True
            Value = "C:\Scripts"
            Target = @('Process', 'Machine')
        }

        		xFirewall Plexos
		{
			Name = 'Plexos-Port-In-TCP'
			Group = 'Web Server'
			Ensure = 'Present'
			Action = 'Allow'
			Enabled = 'True'
			Profile = 'Any'
			Direction = 'Inbound'
			Protocol = 'TCP'
			LocalPort = 339
		}

    }
}
