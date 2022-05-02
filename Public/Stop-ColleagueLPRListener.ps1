Function Stop-ColleagueLPRListener {
   [CmdletBinding()]
   param (
      [parameter(Mandatory = $False, Position = 0)]
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount

   Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
      Stop-Service lpr_DB_Listener
   }
}