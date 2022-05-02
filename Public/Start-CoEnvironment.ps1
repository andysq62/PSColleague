Function Start-CoEnvironment {
   <#
.SYNOPSIS
Starts up all listeners for a Colleague environment.
.DESCRIPTION
Starts up all listeners for a given Colleague environment 
with the exception of the Datatel daemons.  Includes both 
database and applications listeners.
.PARAMETER Environment
The Colleague environment
.PARAMETER IncludeDaemon
this switch will also start up the Datatel daemons for the 
environment.  Not yet implemented.
.EXAMPLE
Start-CoEnvironment -Environment prod

Starts all listeners except the daemons for the prod 
environment.
.NOTES
Listeners must be set to auto start for this function to work.
#>
   [CmdletBinding()]
   param(
      [parameter(mandatory, Position = 0)]
      [ValidateScript( {
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String]$Environment,
      [String]$LogPath = 'D:\Scripts\Logs',
      [Switch]$IncludeDaemon
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $LogFile = Join-Path $LogPath "$($Environment).log"

   # Start DB listener first
   Start-CoListener -Environment $Environment -Name "${Environment}_DB_LISTENER"

   foreach ($L in (Get-ColleagueEnvironment -Environment $Environment)) {
      # Skip the app listener
      If ($L.Listener -eq "${Environment}_APP_LISTENER") {
         Continue
      }
      if ($L.Status -match 'Running') {
         "$($Environment) $($L.Listener) is already Running" | Write-CoLog -LogPath $LogFile
      }
      else {
         "$($Environment) Starting $($L.Listener) on $($L.Host)" | Write-CoLog -LogPath $LogFile
         Invoke-Command -ComputerName $L.Host -Credential $Cred {
            Start-Service -Name $Using:L.Listener
         }
      }
   } # End loop through listeners
   # Start app listener last
   Start-CoListener -Environment $Environment -Name "${Environment}_APP_LISTENER"

   if ($IncludeDaemon.IsPresent) {
      Write-Verbose 'Now Starting Datatel Daemons--Not yet implemented'
   }

}

