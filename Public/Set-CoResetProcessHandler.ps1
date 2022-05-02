Function Set-CoResetProcessHandler {
   <#
.SYNOPSIS
.DESCRIPTION
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE

#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $Apphome = Get-CoApphome -Environment $Environment

   If (!(Get-CoProcessHandlerPid -Environment $Environment)) {
      Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred -ErrorAction SilentlyContinue {
         $PhantActiveQueues = $Using:Apphome + "\PHANTOM.CONTROL\PHANT.ACTIVE.QUEUES"
         if (Test-Path -Path $PhantActiveQueues) {
            Remove-Item -Path $PhantActiveQueues -Force | Out-Null
         }
      }
   }
}

