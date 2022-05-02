Function Get-ColleagueEnvironment {
   <#
.SYNOPSIS
Get-ColleagueEnvironment retrieves information on Colleague 
listeners.
.DESCRIPTION
Get-ColleagueEnvironment retrieves information on Colleague 
listeners into an array of objects.  
Properties includes server, environment, listener name, 
install path, status, and auto maintenance mode.  
.PARAMETER Environment
The Colleague environment for which listener info is gathered.  
.PARAMETER UseReportingNode
This flag will query the Reporting node for the data instead 
of the primary node.  this is useful for reporting.
.EXAMPLE
Get-ColleagueEnvironment -Environment test | Format-List

Retrieves and displays information for all listeners in 
the test environment.
.EXAMPLE
$Listeners = Get-ColleagueEnvironment -Environment prod -UseReportingNode

Retrieves information for all listeners in 
the prod environment, querying the reporting node and stores the data in a variable, which is an array of objects .
.NOTES
This function does not include the Datatel daemons.
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
      [String[]]$Environment,
      [parameter(Position = 1)]
      [String]$AdminAccount = 'ColleagueAdministrator',
      [Switch]$UseReportingNode
   )
   Process {
      $Cred = Get-CoCredential -AdminAccount $AdminAccount
      $q = 'SELECT * FROM dbo.DMILISTENERS WITH (noLock)'
      $ListenerList = @()

      Foreach ($Database in $Environment) {
         $Node = Get-CoSQLNode -Environment $Database
         $AUDMIListeners = Invoke-Command -ComputerName $Node -Credential $Cred {
            Invoke-SQLCmd -database $Using:Database -Query $Using:Q
         }
         $ListenerList += $AUDMIListeners
      }

      $Listeners = @()
      Foreach ($L in $ListenerList) {
         $Status = Invoke-Command -ComputerName $L.DMI_HOST -Credential $Cred {
      (Get-Service -Name $Using:L.DMILISTENERS_ID).Status
         }

         $ListenerKeyStore = Invoke-Command -ComputerName $L.DMI_HOST -Credential $Cred {
      (Get-IniContent (Join-Path $Using:L.DMI_INSTALL_PATH 'dmi.ini'))['No-Section']['ListenerKeyStore']
         }
         if ($ListenerKeyStore) {
            $AutoFlag = $True
         }
         else {
            $AutoFlag = $False
         }

         $obj = New-Object -TypeName PSObject -Property @{
            Listener     = $L.DMILISTENERS_ID
            Host         = $L.DMI_HOST
            InstallPath  = $L.DMI_INSTALL_PATH
            Status       = $Status
            AutoFlag     = $AutoFlag
            SecurePort   = $L.DMI_SECURE_PORT
            UnsecurePort = $L.DMI_PORT
         }
         $Listeners += $obj
      } # End loop through listeners

      $Listeners | Write-Output
   }
}

