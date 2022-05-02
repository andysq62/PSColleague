Function Get-CoAppServer {
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment
   )
   (Import-ColleagueEnvironmentConfig | Where { $_.Environment -eq $Environment }).AppHost | Write-Output
}
