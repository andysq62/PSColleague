Function Invoke-ColleagueMaintenance {
   [CmdletBinding()]
   param(
      [Parameter(Mandatory)]
      [String[]]$Environment,
      [String[]]$EMail = 'SysAdmin'
   )
   $LogPath = 'D:\Scripts\Logs'
   $LogFile = Join-Path $LogPath 'ColleagueMaintenance.log'

   Try {
      "Colleague Maintenance: Now cleaning environments" | Write-CoLog -LogPath $LogFile
      Remove-CoOldFiles -Environment $Environment
      Remove-CoOldDMILogs -Environment $Environment | Out-File (Join-Path $LogPath 'RemovedDMILogs.log') -Force
      Remove-CoFAFiles -Environment $Environment

   }
   Catch [Exception] {
      $_.Exception.message | Write-CoLog -LogPath $LogFile
      "$($_.Exception.Message)" | Send-CoMail -To (Get-CoEmail -EMail $EMail) -Subject 'Colleague Maintenance Error'
   }
}