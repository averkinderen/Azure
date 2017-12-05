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
        $AccountDescription,

        [Parameter(Mandatory = $false)] 
        [ValidateNotNullorEmpty()] 
        [String]$SystemTimeZone="Tonga Standard Time" 
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
            TimeZone = $SystemTimeZone
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