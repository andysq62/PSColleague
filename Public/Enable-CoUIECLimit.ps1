Function Enable-CoUIECLimit {
   <#
.SYNOPSIS
Enables UI limits on a Colleague environment
.DESCRIPTION
Sets connection limits enabled to 'yes' and the environment connection limits to 0.
Allows only authorized users access to UI and Colleague.
.PARAMETER Environment
the Colleague environment
.EXAMPLE
Enable-CoUIECLimit -Environment test

Blocks users from accessing Colleague test
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
   $UIEnvConfigArray[4] = 'Y'
   $UIEnvConfigArray[5] = '0'
   #$UIEnvConfigArray[11] = $UIEnvConfigArray[11].Replace("'","'")

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

