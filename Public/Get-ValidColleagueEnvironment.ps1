Function Get-ValidColleagueEnvironment
{
[CmdletBinding()]
param(
[parameter(Mandatory)]
[String[]]$Environment
)
$Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'

$ValidEnvironments = Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
   Invoke-SQLCMD -Database lpr -Query 'SELECT APPL_ENVIRON_CONFIG_ID FROM dbo.APPL_ENVIRON_CONFIG'
} | Select APPL_ENVIRON_CONFIG_ID

$IsValid = $True

Foreach ($E in $Environment) {
   if(!($ValidEnvironments.APPL_ENVIRON_CONFIG_ID -Contains $E))
   {
      $IsValid = $False
      Break
   }
}

Write-Output $IsValid
}

