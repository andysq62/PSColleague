Function Clear-CoEDXError {
   <#
.SYNOPSIS
.DESCRIPTION
.PARAMETER Environment
The Colleague environment
.EXAMPLE
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [ValidateScript({
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String]$Environment
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $PrimaryNode = Get-CoSQLNode -Environment $Environment
   $Apphome = Get-CoApphome -Environment $Environment

   "$Environment Clearing EDX Errors" | Write-Colog

   Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred {
      Set-Location $Using:Apphome
      $Udt = Join-Path $env:UDTBIN 'udt'
      $CMD = @"
MIOSEL EDX.STATUS WITH EDXS.CRNT.STATUS EQ 'E'
DEL EDX.STATUS
"@
      & $udt $CMD
      #  start-process udt -WorkingDirectory $Using:Apphome -argumentList $PA -Passthru -WindowStyle Hidden
   }
}

