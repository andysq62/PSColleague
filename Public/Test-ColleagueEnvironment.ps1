Function Test-ColleagueEnvironment {
   [CmdletBinding()]
   param(
      [parameter(Mandatory)]
      [String[]]$Environment,
      [Switch]$UseLPR
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'

   If ($UseLPR.IsPresent) {
      $ValidEnvironments = Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
         Invoke-SQLCMD -Database lpr -Query 'SELECT APPL_ENVIRON_CONFIG_ID FROM dbo.APPL_ENVIRON_CONFIG'
      } | Select-Object @{Name = "Environment"; Expression = { $_.APPL_ENVIRON_CONFIG_ID } }
   }
   else {
      $ValidEnvironments = Import-ColleagueEnvironmentConfig
   }

   $IsValid = $True

   Foreach ($E in $Environment) {
      if (!($ValidEnvironments.Environment -Contains $E)) {
         $IsValid = $False
         Break
      }
   }

   Write-Output $IsValid
}

