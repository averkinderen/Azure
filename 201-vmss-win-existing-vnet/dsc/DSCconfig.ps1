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
        [String]$SystemTimeZone="Romance Standard Time" 
    )

    Import-DSCResource -ModuleName xTimeZone 
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

    }
}