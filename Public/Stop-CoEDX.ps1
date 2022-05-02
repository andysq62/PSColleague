Function Stop-CoEDX {
   <#
.SYNOPSIS
Stops EDX for a Colleague environment.
.DESCRIPTION
Stops EDX for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Stop-CoEDX -Environment prod

Stops EDX in the prod 
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
   "$Environment EDX Status Before Stop: $($EdxControl.EDX_CONTROL_TT_FLAG)" | Write-CoLog

   if ($EdxControl.EDX_CONTROL_TT_FLAG -EQ 'H') {
      "$environment EDX is already stopped" | Write-CoLog
   }
   else {
      "$environment Now stopping EDX" | Write-CoLog
      Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $EDXCred {
         Start-Process -FilePath udt.exe -ArgumentList "EDX.PHANTOM.STOP" -WorkingDirectory $Using:Apphome ; Start-Sleep -Seconds 30 
         <#
         Set-Location $Using:Apphome
         $udt = Join-Path $env:UDTBIN 'udt'
         udt 'EDX.PHANTOM.STOP'
         #>
      }
   }
}

