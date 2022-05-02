Function Import-ColleagueEnvironmentConfig {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $False, Position = 0)]
        [String]$Path = 'D:\Scripts\ColleagueEnvironments.xml'
    )
    Import-CliXml $Path | Write-Output 
}