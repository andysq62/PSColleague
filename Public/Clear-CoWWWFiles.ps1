Function Clear-CoWWWFiles {
   <#
.SYNOPSIS
Clears WWW files in a Colleague environment.
.DESCRIPTION
Clear-CoWWWFiles runs two paragraphs in UniData--COUNT.WWW and CLEAR.WWW.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Clear-CoWWWFiles -Environment prod

Runs two UniData paragraphs to clear the WWW files in the prod environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [ValidateScript( {
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
   $Apphome = Get-CoApphome -Environment $Environment

   "$Environment Clearing WWW Files" | Write-Colog

   Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred {
      Set-Location $Using:Apphome
      $Udt = Join-Path $env:UDTBIN 'udt'
      Foreach ($PA in ('COUNT.WWW', 'CLEAR.WWW')) {
         & $udt $PA
         # start-process udt.exe -WorkingDirectory $Using:Apphome -argumentList "${PA}" -WindowStyle Hidden -Wait
      }
   }
}

