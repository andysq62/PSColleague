Function Get-CoApphome {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        [String]$Environment
    )
(Import-ColleagueEnvironmentConfig | Where { $_.Environment -eq $Environment }).Apphome | Write-Output
}