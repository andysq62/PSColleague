Function Get-CoPhantomProcessEntries {
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [ValidateScript({
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String]$Environment
   )

   $PhantomControlFolder = "D:\Ellucian\$Environment\apphome\PHANTOM.CONTROL"

   $Proclist = Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -ArgumentList $PhantomControlFolder {
      Get-ChildItem -Path $Args[0] -File
   }
   $Proclist | Write-Output
}