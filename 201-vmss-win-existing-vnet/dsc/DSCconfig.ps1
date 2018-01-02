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

        Language ConfigureLanguage {
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
            DependsOn = "[Language]ConfigureLanguage"
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
            DestinationPath = "$env:SystemDrive\PLEXOS.Connect.Client.3.00R01.msi"
            MatchSource = $false
            DependsOn = "[File]PlexosFolder"
        }

        Package ConnectClient
        {
        Ensure      = "Present"
        Path        = "$env:SystemDrive\PLEXOS.Connect.Client.3.00R01.msi"
        Name        = "PLEXOS Connect Client"
        ProductId   = "6603B46E-B758-4255-9006-3CB4F273672D"
        Arguments = "SVCUSER=marketsims SVCPASS=Eidolon1989"
        LogPath = "$env:SystemDrive\Installplexos.log"
        DependsOn = "[xRemoteFile]ConnectMSI"
        }

        xScript ConfigPlexos
        {
            SetScript = {
                cmd /c '"C:\Program Files (x86)\Energy Exemplar\PLEXOS Connect Client\connect.client.exe" --server 10.192.40.60 --port 8888 --name "%computername%" --username marketsims --password Eidolon1989 --worker-count 13"'
                }
            TestScript = {$false}
            GetScript = { }
            DependsOn = "[Package]ConnectClient"
            PsDscRunAsCredential = $Credential
        }

        Service Plexosservice
        {
            Name        = "PLEXOS Connect Client Service"
            StartupType = "Automatic"
            State       = "Running"
           DependsOn = "[Script]ConfigPlexos"
        }

    }
}