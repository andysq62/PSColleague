Function Get-ColleagueLPRListener {
   [CmdletBinding()]
   param (
      [parameter(Mandatory = $False, Position = 0)]
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount

   Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
      Get-Service lpr_DB_Listener
   }
}