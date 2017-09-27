#Requires -version 4.0 
Configuration SetTimeZone 
{ 
    Param 
    ( 
        #Target nodes to apply the configuration 
        [Parameter(Mandatory = $false)] 
        [ValidateNotNullorEmpty()] 
        [String]$SystemTimeZone="Romance Standard Time" 
    ) 

    Import-DSCResource -ModuleName xTimeZone 

    Node localhost 
    { 
        xTimeZone TimeZoneExample 
        { 
            TimeZone = $SystemTimeZone
        } 
    } 
}