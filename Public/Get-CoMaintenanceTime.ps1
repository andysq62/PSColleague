function Get-CoMaintenanceTime {
    [CmdletBinding()]
    param(
        [String]$DayOfWeek = 'Saturday',
        [Int32]$BeginHour = 5,
        [Int32]$EndHour = 9
    )    
    $Maintenance = $False
    $Now = Get-Date
    $NowHour = $Now.TimeOfDay.Hours

    "NowHour: $($NowHour)" | Write-Verbose

    If ($Now.DayOfWeek -eq $DayOfWeek) {
        If (($NowHour -GT ($BeginHour - 1)) -and ($NowHour -lt $EndHour)) {
            $Maintenance = $True
        }
    }
    $Maintenance | Write-Output
}