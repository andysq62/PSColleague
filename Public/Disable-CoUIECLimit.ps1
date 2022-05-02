Function Disable-CoUIECLimit {
   <#
.SYNOPSIS
Disables UI limits on a Colleague environment
.DESCRIPTION
Sets connection limits enabled to 'No' and the environment connection limits to null, i.e. ''.
Allows all users access to UI and Colleague.
.PARAMETER Environment
the Colleague environment
.EXAMPLE
Disable-CoUIECLimit -Environment test

Opens access to Colleague test for all users.
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $PrimaryNode = Get-CoSQLNode -Environment $Environment

   $UIEnvConfigArray = @()
   $UIEnvConfigArray = Get-CoUIEC -Environment $Environment
   $UIEnvConfigArray | Out-File "D:\Scripts\UIEnvConfig${environment}.txt"
   $UIEnvConfigArray[4] = 'N'
   $UIEnvConfigArray[5] = ''

   $UIEnvConfig = [String]::Join([char]254, $UIEnvConfigArray)
   $Q = @"
UPDATE [dbo].[PARMS] SET PARMS_RCD = '$UIEnvConfig'
WHERE PARMS_ID = 'UI.ENV.CONFIG~UT'
"@

   Write-Verbose $Q


   $Result = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
      Invoke-SQLCmd -Database $Using:Environment -Query $Using:Q
   }


   $Result | Write-Output
}

