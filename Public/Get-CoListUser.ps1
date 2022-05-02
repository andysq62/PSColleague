Function Get-CoListUser {
   <#
.SYNOPSIS
.DESCRIPTION
.PARAMETER Environment
The Colleague environment
.PARAMETER AdminAccount
.EXAMPLE
#>
   [CmdletBinding()]
   param (
      [parameter(Mandatory, Position = 0)]
      [String]$Environment,
      [String]$AdminAccount = 'ColleagueAdministrator'
   )
   $Cred = get-CoCredential -AdminAccount $AdminAccount

   $ListUser = Invoke-Command -ComputerName (Get-CoAppServer -Environment $Environment) -Credential $Cred {
      listuser
   }

   $Start = 6
   $End = $Listuser.Count - 2
   $Procs = @()
   $ListUser[$Start..$End] | Foreach {
      $UdtProc = ($_.Trim()) -Split '\s+', 8
      $Obj = New-Object -TypeName PSObject -Property @{
         UdtNo     = $UdtProc[0]
         UserNum   = $UdtProc[1]
         UID       = $UdtProc[2]
         UserName  = $UdtProc[3]
         UserType  = $UdtProc[4]
         TTY       = $UdtProc[5]
         IPAddress = $UdtProc[6]
         DateTime  = [DateTime]$UdtProc[7]
      }
      $Procs += $Obj
   }
   Write-Output $Procs
}
