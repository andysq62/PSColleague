Function Invoke-CoGrantExecOnScalarFunctions {
   <#
.SYNOPSIS
Invoke-CoGrantExecOnScalarFunctions Runs the sp_grant_exec_on_scalar_functions 
stored procedure in the provided environments.  It outputs 
a text file with the generated SQL statements, and then 
runs those statements in the listed environments.
.DESCRIPTION
Invoke-CoGrantExecOnScalarFunctions selects the 
corresponding primary node for listed environments and runs 
the sp_grant_exec_on_scalar_functions stored procedure, 
generates a flat file, and runs the generated SQL.

.PARAMETER Environment
The environment/database in which the stored procedure and generated 
SQL will be run.
.EXAMPLE
Invoke-CoGrantExecOnScalarFunctions -Environment test

Runs the stored procedure and generated SQL in the primary node of the test environment.
.EXAMPLE
Invoke-CoGrantExecOnScalarFunctions -Environment prod,test -Verbose

Runs the stored procedure and generated SQL on the primary 
nodes for the production and test environments, and 
displays verbose output.
#>
   [CmdletBinding()]
   param(
      [parameter(Mandatory, Position = 0)]
      [ValidateScript({
            If (!(Test-ColleagueEnvironment -Environment $_)) {
               Throw "One or more environments is invalid...try again."
            }
            else {
               $True
            } 
         })]
      [String[]]$Environment,
      [String]$EMail = 'DBA'
   )
   $Query = 'exec sp_grant_exec_on_scalar_functions'
   $Cred = Get-CoCredential -AdminAccount 'ColleagueAdministrator'

   Foreach ($E in $Environment) {
      $PrimaryNode = Get-CoSQLNode -Environment $E
      "Running grant exec on scalar functions on $E $PrimaryNode" | Write-CoLog

      $Result = Invoke-Command -Computername $PrimaryNode -Credential $Cred {
         $SQLFile = 'D:\Scripts\GrantExecOnScalarFunctions.sql'
         $Database = $Using:E

         $SQLOutput = Invoke-SQLCmd -Database $Database -Query $Using:Query -QueryTimeout 0
         $SQLOutput.Script | out-File -FilePath $SQLFile -Force

         If (Test-Path -Path $SQLFile) {
            Invoke-SQLCmd -Database $Database -InputFile $SQLFile -QueryTimeout 0
         }
      }  # End Invoke Command

      If ($Result) {
         "${E}: $Result" | Write-CoLog
      }


   }  # End loop through environments.

   'Grant Exec On Scalar Functions Complete' | Send-CoMail -To (Get-CoEmail -EMail $EMail) -Subject ('Grant Exec On Scalar Functions are complete in ' + ($Environment -Join ', '))

}

