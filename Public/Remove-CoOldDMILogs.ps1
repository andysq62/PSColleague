Function Remove-CoOldDMILogs {
   <#
.SYNOPSIS
Removes all old DMI logs for a given environment
.DESCRIPTION
Retrieves data for all listeners associated with an 
environment and cleans out old dmi.log.* files.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Remove-CoOldDMILogs -Environment prod

Removes all DMI log files for all listeners in the prod 
environment.
#>
   [Cmdletbinding()] 
   param(
      [parameter(Mandatory, ValueFromPipeline, Position = 0)]
      [ValidateScript({
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
   $Listeners = Get-ColleagueEnvironment -Environment $Environment

   Foreach ($l in $listeners) {
      Write-Verbose ("Host: " + $L.HOST + "Install Path: " + $L.InstallPath)
      $Res = Invoke-Command -ComputerName $L.HOST -Credential $Cred -ArgumentList ($L.InstallPath) {
         $Files = Get-ChildItem -Path ($Args[0] + '\dmi.log*') -Exclude dmi.log -File | 
         Where { $_.Lastwritetime -lt (Get-Date).AddDays(-1) }
         if ($Files.count -gt 0) {
            $Files | Remove-Item
            $Files.fullname
         }
      }
      $Result += $Res
   } # End for loop
   Write-Output $result
}  #End Function

