Function Get-CoUIEC {
   <#
.SYNOPSIS
Retrieves an object showing the state of UIEC limits.
.DESCRIPTION
Returns an object with the value of whether connection limits are enabled and
the value of environment connection limits.
.PARAMETER Environment
the Colleague environment
.EXAMPLE
Get-CoUIECLimit -Environment test

Retrieves the status of UIEC limits for the test environment.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [Parameter(Mandatory = $False)]
      [Switch]$AsString,
      [Parameter(Mandatory = $False)]
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $PrimaryNode = Get-CoSQLNode -Environment $Environment
   $Q = "SELECT * FROM dbo.PARMS WHERE PARMS_ID = 'UI.ENV.CONFIG~UT'"

   $UIEnvConfig = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
      Invoke-SQLCmd -Database $Using:Environment -Query $Using:Q
   }

   $UIECArray = ($UIEnvConfig.PARMS_RCD.Split([Char]254))

   If ($AsString.IsPresent) {
      $Output = $UIEnvConfig.PARMS_RCD
   }
   else {
      $Output = $UIECArray
   }
   $Output | Write-Output
}

