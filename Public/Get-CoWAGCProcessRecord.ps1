Function Get-CoWAGCProcessRecord {
   <#
.SYNOPSIS
Retrieves the WAGC process record.
.DESCRIPTION
Get-CoWAGCProcessRecord retrieves the process record of WAGC in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-CoWAGCProcessRecord -Environment test

Retrieves the WAGC Process Record for the test environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $PrimaryNode = Get-CoSQLNode -Environment $Environment
   $WAGCStatusFieldNo = 0
   $WAGCUserFieldNo = 9
   $WAGCPidFieldNo = 12
   $WAGCComoFieldNo = 13
   $WAGCAlertEMailFieldNo = 14

   $Q = "SELECT * FROM dbo.PARMS WHERE PARMS_ID = 'GC.STATUS~UT'"

   $GCStatus = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
      Invoke-SQLCmd -Database $Using:Environment -Query $Using:Q
   }
   $WAGCRec = @{
      STATUS     = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCStatusFieldNo]
      User       = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCUserFieldNo]
      COMO       = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCComoFieldNo]
      AlertEMail = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCAlertEMailFieldNo]
      PID        = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCPidFieldNo].Split(' ')[0]
   }

   $WAGCRec | Write-Output
}

