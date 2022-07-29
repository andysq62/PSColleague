Function Get-IsSQLSynchronized
{
[CmdletBinding()]
Param (
[String]$Name
)
((Get-DBAAGReplica -SQLInstance $Name -Replica $Name).RollupSynchronizationState -EQ 'Synchronized') | Write-Output
}