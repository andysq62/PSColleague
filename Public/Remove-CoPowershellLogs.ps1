Function Remove-CoPowershellLogs {
   [CmdLetBinding()]
   param(
      [Parameter()]
      [String[]]$ComputerName = (Get-Content "D:\Scripts\ColleagueServers.txt"),
      [Parameter()]
      [String]$Path = 'C:\Logs\Powershell',
      [Int32]$Days = 90
   )
   $Cred = Get-CoCredential -AdminAccount 'ColleagueMonitor'

   Invoke-Command -ComputerName $ComputerName -Credential $Cred {
      If (Test-Path -Path $Using:Path) {
         Get-ChildItem -Path $Using:Path -ErrorAction SilentlyContinue | Where { $_.LastWritetime -lt (Get-Date).AddDays(-$Using:Days) } | Remove-Item -Recurse -Force
      }
   }

}