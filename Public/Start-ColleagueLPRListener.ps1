Function Start-ColleagueLPRListener {
   [CmdletBinding()]
   param (
      [parameter(Mandatory = $False, Position = 0)]
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount

   Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
      If ((Get-Service LPR_DB_Listener).Status -ne 'Running') {
         Start-Service lpr_DB_Listener
      }
   }
}