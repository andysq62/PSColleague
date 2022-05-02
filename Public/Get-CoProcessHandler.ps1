Function Get-CoProcessHandler {
   <#
.SYNOPSIS
Retrieves the process handler process ID.
.DESCRIPTION
Get-CoProcessHandlerStatus retrieves the process ID of Process Handler in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-CoProcessHandlerStatus -Environment test

Retrieves the Process Handler Status for the test environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $ProcessHandlerPid = Get-CoProcessHandlerPid -Environment $Environment
   $ProcessHandler = $Null

   if ($ProcessHandlerPid) {
      $ProcessHandler = Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred -ErrorAction SilentlyContinue {
         Get-Process -id $Using:ProcessHandlerPid -IncludeUserName
      }
   }

   $ProcessHandler | Write-Output
}

