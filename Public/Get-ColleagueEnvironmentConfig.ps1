Function Get-ColleagueEnvironmentConfig {
   [CmdletBinding()]
   param (
      [parameter(Mandatory = $False, Position = 0)]
      [String]$EnvironmentBasePath = 'D:\Ellucian',
      [parameter(Mandatory = $False, Position = 1)]
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = Get-CoCredential -AdminAccount $AdminAccount
   $Query = "SELECT * FROM dbo.APPL_ENVIRON_CONFIG"

   Write-Verbose "Query: $Query"

   $EnvConfig = Invoke-Command -ComputerName (Get-CoLPRHost) -Credential $Cred {
      Invoke-SQLCMD -Database lpr -Query $Using:Query
   }

   $Obj = @()
   $EnvConfig | Foreach {
      $Environment = $_.APPL_ENVIRON_CONFIG_ID
      $DBHost = $_.AEC_DBAS_HOST

      $Query2 = "SELECT * FROM dbo.DMILISTENERS WHERE DMILISTENERS_ID='${Environment}_APP_LISTENER'"
      $APPHost = Invoke-Command -ComputerName $DBHost -Credential $Cred {
         Invoke-SQLCmd -Database $Using:Environment -Query $Using:Query2
      }

      $Obj += New-Object -TypeName PSObject -property @{
         Environment      = $Environment
         Apphome          = "${EnvironmentBasePath}\${Environment}\Apphome"
         AppHost          = $AppHost.DMI_HOST
         DBHost           = $DBHost
         InstallPath      = $_.AEC_DBAS_INSTALL_PATH
         DatabaseLocation = $_.AEC_DBAS_DATABASE_LOCATION
      }
   }

   $Obj | Write-Output
}
