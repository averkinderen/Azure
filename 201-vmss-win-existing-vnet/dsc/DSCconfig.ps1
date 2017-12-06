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
        $AccountDescription
    )

    Import-DSCResource -ModuleName 'xTimeZone'
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'
    Node Localhost
    {
        User NewUser
        {
            UserName             = $Credential.UserName
            Description          = $AccountDescription
            Disabled             = $false
            Ensure               = 'Present'
            Password             = $Credential.Password
            PasswordNeverExpires = $true
        }

        xTimeZone TimeZoneExample 
        { 
            TimeZone = "Tonga Standard Time"
        } 

                xEnvironment CreatePathEnvironmentVariable
        {
            Name = 'TestPathEnvironmentVariable'
            Value = 'TestValue'
            Ensure = 'Present'
            Path = $true
            Target = @('Process', 'Machine')
        }

    }
}