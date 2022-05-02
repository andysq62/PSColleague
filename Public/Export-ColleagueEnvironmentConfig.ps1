Function Export-ColleagueEnvironmentConfig {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        [String]$Path,
        [parameter(Mandatory = $False, Position = 1)]
        [String]$AdminAccount = 'ColleagueAdministrator'
    )
    $Cred = Get-CoCredential -AdminAccount $AdminAccount
    Get-ColleagueEnvironmentConfig | Export-CliXML $Path
}