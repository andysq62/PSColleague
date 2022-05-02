Function Remove-CoOldFiles {
   [CmdletBinding()]
   param(
      [parameter(Mandatory, Position = 0)]
      [ValidateScript( {
            If (!(Test-CoEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String[]]$Environment
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'
   $Q = 'DELETE FROM [dbo].[UI_LOG_INFO] WHERE [UI_LOG_INFO_ID] IS NOT NULL AND [UI_LOG_INFO_ADD_DATE] < (GETDATE()-366)'

   Foreach ($E in $Environment) {

      $BasePath = "D:\Ellucian\$($E)"
      $Apphome = Get-CoApphome -Environment $E
      Invoke-Command -ComputerName (Get-CoAppServer -Environment $E) -Credential $Cred {
         $_PH_ = Join-Path $Using:Apphome '_PH_'
         $_HOLD_ = Join-Path $Using:Apphome '_HOLD_'
         $SAVEDLISTS = Join-Path $Using:Apphome 'SAVEDLISTS'
         $FILETRANSFERS = Join-Path $Using:BasePath 'FILETRANSFERS'
         $Dest1ReportLogs = Join-Path $Using:Apphome 'DEST1.REPORT.LOGS'

         If (Test-Path $Using:Apphome) {
            $Files = Get-ChildItem $Using:Apphome |
            Where { $_.Name -Match '[A-Za-z0-9]{2,8}_TRAN_EXTRACT_\d{2,5}_\d{2,5}' }
            $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedTranExtractFiles.log -Force
            $Files | Remove-Item -ErrorAction 'SilentlyContinue'
         }

         If (Test-Path $_PH_) {
            $Files = Get-ChildItem $_PH_ |
            Where { $_.Lastwritetime -lt (Get-Date).AddDays(-7) -or $_.Name -Match '^[A-Z]{2,8}\d{2,5}_\d{2,5}' }
            $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedPHFiles.log -Force
            $Files | Remove-Item -ErrorAction 'SilentlyContinue'
         }


         If (Test-Path $_HOLD_) {
            $Files = Get-ChildItem $_HOLD_ -Exclude *PRIVATE*, *KEEP* | 
            Where { $_.Lastwritetime -lt (Get-Date).AddDays(-10) }
            $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedHOLDFiles.log -Force
            $Files | Remove-Item -ErrorAction 'SilentlyContinue'
         }


         If (Test-Path $SAVEDLISTS) {
            $Files = Get-ChildItem $SAVEDLISTS -Exclude *KEEP* | 
            Where { $_.Lastwritetime -lt (Get-Date).AddDays(-30) }
            $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedSLFiles.log -Force
            $Files | Remove-Item -ErrorAction 'SilentlyContinue'
         }

         If (Test-Path $Dest1ReportLogs) {
            $Files = Get-ChildItem $Dest1ReportLogs |
            Where { $_.Lastwritetime -lt (Get-Date).AddDays(-30) }
            $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedDest1Files.log -Force
            $Files | Remove-Item -ErrorAction 'SilentlyContinue'
         }


         $UIExportDir = Join-Path $Using:Apphome 'UI.EXPORT.DIR'
         If (Test-Path -Path $UIExportDir) {
            Get-ChildItem $UIExportDir -Exclude ExcelExport.xlsx | Remove-Item
         }

         $CommonAppPath = Join-Path $FileTransfers 'A26.AD.COMMON.APP'
         If (Test-Path $CommonAppPath) {
            $Files = Get-ChildItem $CommonAppPath | 
            Where { $_.Lastwritetime -lt (Get-Date).AddDays(-60) }
            $Files | Out-File D:\Scripts\Logs\RemovedCommonAppFiles.log -Force
            $Files | Remove-Item -Force
         }
      }     #End Invoke Command

      # Now clean UI_LOG_INFO table
      Invoke-Command -ComputerName (Get-CoSQLNode -Environment $E) -Credential $Cred {
         Invoke-SQLCmd -Database $Using:E -Query $Using:Q
      }

      Invoke-CoUniDataCommand -Environment $E -Name 'A26.CLEAR.UT.THROWN.ERRORS'

   }     #End loop through environments
}