Function Clear-CoUtThrownErrors {
   <#
.SYNOPSIS
Clears UT.THROWN.ERRORS in a Colleague environment.
.DESCRIPTION
Clears records more than 7 days old from UT.THROWN.ERRORS
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Clear-CoUtThrownErrors -Environment prod

Removes records more than 7 days old from the UT.THROWN.ERRORS UniData file.
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

   "$Environment Clearing UT.THROWN.ERRORS Records" | Write-Colog

   Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred {
      Set-Location $Using:Apphome
      $Udt = Join-Path $env:UDTBIN 'udt'
      Foreach ($PA in ('COUNT.WWW', 'CLEAR.WWW')) {
         & $udt $PA
         #  start-process udt -WorkingDirectory $Using:Apphome -argumentList $PA -Passthru -WindowStyle Hidden
      }
   }
}

