Function Remove-CoFAFiles {
   [CmdletBinding()]
   param(
      [parameter(Mandatory, Position = 0)]
      [ValidateScript( {
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String[]]$Environment
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'

   $FADirs = @('FA.TEXT.RECEIVE.DIR',
      'FA.UFT.RECEIVE.DIR',
      'FA.DELIM.RECEIVE.DIR',
      'FA.RCV.ARCH.DIR',
      'FA.COD.LOG.DIR',
      'FA.SEND.ARCH.DIR')

   $Environment | ForEach {
      $Apphome = Get-CoApphome -Environment $_

      $Params = @{  
         ComputerName = (Get-CoAppServer -Environment $_) 
         ScriptBlock  = {
            Param([String]$Apphome, [String[]]$FADirs)

            $FADirs | ForEach {
               $Path = Join-Path -Path $Apphome -ChildPath $_

               If (Test-Path $Path) {
                  $Files = Get-ChildItem $Path |
                  Where { $_.Lastwritetime -lt (Get-Date).AddDays(-730) }
                  $Files | Remove-Item -ErrorAction 'SilentlyContinue'
                  $NumFilesRemoved += "$($_): $($Files.count)"
               }
            }    # End loop through folders
            $NumFilesRemoved | Out-File D:\Scripts\Logs\RemovedFAFiles.log -Force
         }    # End scriptblock
         Credential   = $Cred
         ArgumentList = ($Apphome, $FADirs)
      }
      Invoke-Command @Params 
        

        
   }    # End Loop through environments
}    # End Function