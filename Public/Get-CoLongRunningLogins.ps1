function Get-CoLongRunningLogins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Environment,
        [Int]$UserHoursOld = 24,
        [Int]$PHHoursOld = 12,
        [Int]$EDXHoursOld = 6
    )

    $PHUser = ((Get-CoCredential -AdminAccount 'ProcessHandler').UserName).SubString(0, 9)
    $EDXUser = (Get-CoCredential -AdminAccount 'EDXManager').UserName
    $ColleagueAdministrator = (Get-CoCredential -AdminAccount 'ColleagueAdministrator').UserName

    $LongRunningPHProcs = @()
    $LongRunningUserProcs = @()
    
    $ProcessHandlerPID = Get-CoProcessHandlerPid -Environment $Environment

    $LongRunningPHProcs = Get-CoListUser -Environment $Environment | Where-Object {
        ($_.UserName -match $pHUser) -and
        ($_.UserNum -notmatch "$ProcessHandlerPID") -and
        ($_.DateTime -lt (Get-Date).AddHours(-$PHHoursOld))
    }
    
    $LongRunningUserProcs = Get-CoListUser -Environment $Environment | Where-Object {
        ($_.UserName -notmatch $ColleagueAdministrator) -and
        ($_.UserName -notmatch $EDXUser) -and
        ($_.UserName -notmatch $PHUser) -and
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