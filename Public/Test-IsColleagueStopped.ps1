Function Test-IsColleagueStopped {
   [CmdletBinding()]
   param(
      [parameter(Mandatory)]
      [String]$Environment
   )

   $IsStopped = $true

   Get-ColleagueEnvironment -Environment $Environment | ForEach {
      If ($_.Status.value -notmatch 'Stopped') {
         $IsStopped = $false
      }
   }

   $IsStopped | Write-Output
}

