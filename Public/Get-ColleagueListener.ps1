Function Get-ColleagueListener {
   <#
.SYNOPSIS
Get-ColleagueListener retrieves information on specific Colleague 
listeners.
.DESCRIPTION
Get-ColleagueListener retrieves information on specific Colleague 
listeners into an array of objects.  
Information includes server, environment, listener name, 
install path, Ports, status, and auto maintenance mode.  Listeners can
be selected by either name or port number.
.PARAMETER Environment
The Colleague environment for which listener info is gathered.  
.PARAMETER Name
the name(s) of the listener(s) to be retrieved.
.PARAMETER Port
the list of ports corresponding to the listeners to be retrieved.
.PARAMETER UseReportingNode
This flag will query the reporting node for the data instead of the primary node.  
.EXAMPLE
$Listeners = @('test_APP_LISTENER','test_SS_LISTENER','test_WA_LISTENER')
Get-ColleagueListener -Name $Listeners -Environment test | Format-List

Retrieves and displays information for all applications 
listeners in the test environment.
.EXAMPLE
Get-ColleagueListener -Environment test -Port 7400,7412

Retrieves and displays information for the 
listeners in the test environment using ports 7400 and 7412.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [parameter(ParameterSetName = 'ByName')]
      [parameter(ParameterSetName = 'ByPort')]
      [ValidateScript({
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String]$Environment,
      [parameter(Mandatory, ParameterSetName = 'ByName')]
      [String[]]$Name,
      [parameter(Mandatory, ParameterSetName = 'ByPort')]
      [Int32[]]$Port,
      [Switch]$UseReportingNode
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $q = 'SELECT * FROM dbo.DMILISTENERS'
   $ListenerList = @()

   if ($UseReportingNode.IsPresent) {
      $Node = Get-CoSQLNode -Environment $Environment -UseReportingNode
   }
   else {
      $Node = Get-CoSQLNode -Environment $Environment
   }

   Write-Verbose "PSet: $($PSCmdlet.ParameterSetName)"

   $ListenerList = Invoke-Command -ComputerName $Node -Credential $Cred {
      Invoke-SQLCmd -database $Using:Environment -Query $Using:q
   } 

   If ($PSCmdlet.ParameterSetName -eq 'ByName') {
      $ListenerList = $ListenerList | Where { $Name -Contains $_.DMILISTENERS_ID }
   }
   elseif ($PSCmdlet.ParameterSetName -eq 'ByPort') {
      $ListenerList = $ListenerList | Where { ($Port -Contains $_.DMI_SECURE_PORT) -or ($Port -contains $_.DMI_PORT) }
   }
   else {
      Write-Verbose "No param set"
   }


   $Listeners = @()

   Foreach ($L in $ListenerList) {

      Write-Verbose "L.DMI_HOST: $($L.DMI_HOST)"

      $ListenerState = Invoke-Command -ComputerName $L.DMI_HOST -Credential $Cred {
         $Status = (Get-Service -Name $Using:L.DMILISTENERS_ID).Status

         $KeyStore = (Get-IniContent (Join-Path $Using:L.DMI_INSTALL_PATH 'dmi.ini'))['No-Section']['ListenerKeyStore']
         if ($KeyStore) {
            $AutoFlag = $True
         }
         else {
            $AutoFlag = $False
         }

         $obj = New-Object -TypeName PSObject -Property @{
            Status   = $Status
            AutoFlag = $AutoFlag
         }

         $Obj | Write-Output
      }     # End Invoke Command


      $Listeners += New-Object -TypeName PSObject -Property @{
         Listener     = $L.DMILISTENERS_ID
         Host         = $L.DMI_HOST
         InstallPath  = $L.DMI_INSTALL_PATH
         Status       = $ListenerState.Status
         AutoFlag     = $ListenerState.AutoFlag
         SecurePort   = $L.DMI_SECURE_PORT
         UnsecurePort = $L.DMI_PORT
      }
   } # End loop through listeners

   $Listeners | Write-Output
}

