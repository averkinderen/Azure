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

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'
    Node $nodeName
    PsDscAllowPlainTextPassword = $true
    {
            User NewUser
        {
            UserName             = $Credential.UserName
            Disabled             = $false
            Ensure               = 'Present'
            Password             = $Credential.Password
            PasswordNeverExpires = $true
        }

                xEnvironment CreatePathEnvironmentVariable
        {
            Name = 'PLEXOS_TEMP'
            Value = 'F:\Temp'
            Ensure = 'Present'
            Path = $true
            Target = @('Process', 'Machine')
        }

    }
}