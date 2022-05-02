function Get-CoLongRunningLogins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Environment,
        [Int]$UserHoursOld = 24,
        [Int]$PHHoursOld = 12,
        [Int]$EDXHoursOld = 6
    )

    $LongRunningPHProcs = @()
    $LongRunningUserProcs = @()
    
    $ProcessHandlerPID = Get-CoProcessHandlerPid -Environment $Environment

    $LongRunningPHProcs = Get-CoListUser -Environment $Environment | Where-Object {
        ($_.UserName -match 'svcprcsha') -and
        ($_.UserNum -notmatch "$ProcessHandlerPID") -and
        ($_.DateTime -lt (Get-Date).AddHours(-$PHHoursOld))
    }
    
    $LongRunningUserProcs = Get-CoListUser -Environment $Environment | Where-Object {
        ($_.UserName -notmatch 'ellucian') -and
        ($_.UserName -notmatch 'SvcEDXMgr') -and
        ($_.UserName -notmatch 'Svcprcsha') -and
        ($_.DateTime -lt (Get-Date).AddHours(-$UserHoursOld))
    }

    $TotalProcs = @()
    $LongRunningUserProcs | ForEach-Object {
        $TotalProcs += $_
    }
    $LongRunningPHProcs | ForEach-Object {
        $Obj = Get-CoPhantomUserProcess -UserNum $_.UserNum -DateTime $_.Datetime
        $_ | Add-Member -NotePropertyName PSDT_User -NotePropertyValue $Obj.PSDT_User
        $_ | Add-Member -NotePropertyName COMO -NotePropertyValue $Obj.PSDT_CRT_COMO_NAME
        $_ | Add-Member -NotePropertyName MNEMONIC -NotePropertyValue $Obj.PSDT_MNEMONIC
        $_ | Add-Member -NotePropertyName KEY -NotePropertyValue $Obj.KEY

        $TotalProcs += $_
    }
    $TotalProcs | Write-Output
}