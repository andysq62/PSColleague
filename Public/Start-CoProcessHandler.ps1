Function Start-CoProcessHandler {
   <#
.SYNOPSIS
Starts the Process Handler for a Colleague environment.
.DESCRIPTION
Starts the Process Handler for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-CoProcessHandler -Environment prod

Starts the Process Handler in the prod 
environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment
   )
   $ProcessHandlerCred = Get-CoCredential -AdminAccount 'ProcessHandler'
   $Cred = get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $Apphome = Get-CoApphome -Environment $Environment
   $AppServer = Get-CoAppServer -Environment $Environment

   $PHPid = Get-CoProcessHandlerPid -Environment $Environment -ErrorAction SilentlyContinue
   If ($PHPid) {
      If (Get-Process -ComputerName $AppServer -Id $PHPid -ErrorAction SilentlyContinue) {
         "${Environment}: Process Handler Appears to be Running...Exiting" | Write-CoLog
         Return
      }
   }

   "$environment Now starting process handler" | Write-CoLog

   $Result = Invoke-Command -ComputerName $AppServer -Credential $ProcessHandlerCred {
      Start-Process -FilePath udt.exe -Workingdirectory $Using:Apphome -ArgumentList "A26.START.PROCESS.HANDLER" ; Start-Sleep -Seconds 30
   }
}

