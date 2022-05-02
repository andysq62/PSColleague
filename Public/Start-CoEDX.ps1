Function Start-CoEDX {
   <#
.SYNOPSIS
Starts EDX for a Colleague environment.
.DESCRIPTION
Starts EDX for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-CoEDX -Environment prod

Starts EDX in the prod 
environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment
   )
   $EDXCred = Get-CoCredential -AdminAccount 'EDXManager'
   $Cred = get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $PrimaryNode = Get-CoSQLNode -Environment $Environment
   $q = "SELECT * FROM dbo.EDX_CONTROL WHERE EDX_CONTROL_ID = 'EDX'"
   $Apphome = Get-CoApphome -Environment $Environment

   $EdxControl = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
      Invoke-SqlCmd -Database $Using:Environment -Query $Using:Q
   }
   "$environment EDX status before start: $($EdxControl.EDX_CONTROL_TT_FLAG)" | Write-CoLog

   if ($EdxControl.EDX_CONTROL_TT_FLAG -EQ 'S') {
      "$environment EDX is already running" | Write-CoLog
   }
   else {
      "$environment Now starting EDX" | Write-CoLog
      Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $EDXCred {
         Start-Process -FilePath udt.exe -ArgumentList "EDX.PHANTOM.START" -WorkingDirectory $Using:Apphome ; Start-Sleep -Seconds 30
         <#
      $udt = Join-Path $env:UDTBIN 'udt'
      Set-Location $Using:Apphome
       udt 'EDX.PHANTOM.STARTUP'
       #>
      }
   }
}

