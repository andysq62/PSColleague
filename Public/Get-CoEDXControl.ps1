Function Get-CoEDXControl {
   <#
.SYNOPSIS
Retrieves the EDX Control record.
.DESCRIPTION
Retrieves the EDX Control 'EDX' record for the given 
environment.
.PARAMETER Environment
the Colleague environment
.EXAMPLE
Get-CoEDXControl -Environment test | Format-List

Retrieves the EDX Control record for the test environment and displays the field values.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $PrimaryNode = Get-CoSQLNode -Environment $Environment
   $q = "SELECT * FROM dbo.EDX_CONTROL WHERE EDX_CONTROL_ID = 'EDX'"

   $EdxControl = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
      Invoke-SqlCmd -Database $Using:Environment -Query $Using:Q
   }
   Write-Verbose $EdxControl.EDX_CONTROL_TT_FLAG
   $EDXControl | Write-Output
}

