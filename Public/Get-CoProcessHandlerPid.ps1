Function Get-CoProcessHandlerPid {
   <#
.SYNOPSIS
Retrieves the process handler process ID.
.DESCRIPTION
Get-CoProcessHandlerPid retrieves the process ID of Process Handler in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-CoProcessHandlerPid -Environment test

Retrieves the Process Handler Pid for the test environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $Apphome = Get-CoApphome -Environment $Environment
   $ProcessHandlerPid = $Null

   $ProcessHandlerPid = Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred -ErrorAction SilentlyContinue {
      $Result = $Null
      $PhantActiveQueues = $Using:Apphome + "\PHANTOM.CONTROL\PHANT.ACTIVE.QUEUES"
      if (Test-Path -Path $PhantActiveQueues) {
         $pattern = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
         $IPAddress = (Get-Content $PhantActiveQueues)[10].split(' ')[1]
         $PHPID = (Get-Content $PhantActiveQueues)[10].split(' ')[0]
         If (($IPAddress -match $pattern) -and ($PHPID -match '\d{3,5}') -and ((Get-Process -id $PHPid -ErrorAction SilentlyContinue))) {
            $Result = $PHPID
         }
      }
      else {
         $Result = $Null
      }
      $Result
   }
   $ProcessHandlerPid | Write-Output
}

