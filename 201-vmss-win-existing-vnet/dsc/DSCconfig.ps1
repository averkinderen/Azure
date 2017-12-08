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

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking

    Node $nodeName


                xEnvironment CreatePathEnvironmentVariable
        {
            Name = 'PLEXOS_TEMP'
            Value = 'F:\Temp'
            Ensure = 'Present'
            Path = $true
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