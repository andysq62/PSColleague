Function Restart-COSQLComputer {
    [CmdletBinding()]
    param(
        [String]$ComputerName,
        [String]$Database
    )

    $ErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    $LogFile = "D:\Scripts\Logs\$($ComputerName).log"

    $DBTimeOut = 120
    $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch

    $Params = @{
        SQLInstance = $ComputerName
        Replica     = $ComputerName
    }

    While ($True) {
        $Replica = Get-DbaAgReplica @Params
        If (($Replica.Role -eq 'secondary') -and ($Replica.RollupSynchronizationState -eq 'synchronized')) {
            "$($ComputerName) is a secondary replica--Proceeding with reboot" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
            $msg | Write-Verbose
            break
        }
        else {
            "$($ComputerName) is either a primary or is not synchronized" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
            $msg | Write-Verbose
            Start-Sleep -Seconds 30
        }
    }

    "Now rebooting $($ComputerName)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
    $msg | Write-Verbose
    Restart-Computer -ComputerName $ComputerName -Wait -for Powershell -Force
    Start-Sleep -Seconds 30

    #    While (-Not (Get-AUIsSQLRunning -ComputerName $ComputerName)) { Start-Sleep -Seconds 20 }
    While (-Not (Test-DbaConnection -SQLInstance $ComputerName).ConnectSuccess) { Start-Sleep -Seconds 20 }

    $StopWatch.Start()
    While ((!((Get-DbaDatabase -SqlInstance $ComputerName -Database $Database -ErrorAction SilentlyContinue).IsAccessible)) -and ($StopWatch.Elapsed.TotalSeconds -lt $DBTimeOut)) {
        Start-Sleep -Seconds 20
    }
    If ($StopWatch.Elapsed.TotalSeconds -ge $DBTimeOut) {
        Throw "Cannot reach $($ComputerName) or timed out"
    }
    $StopWatch.Stop()

    If ((Test-PendingReboot -ComputerName $ComputerName -SkipPendingFileRenameOperationsCheck).IsRebootPending) {
        "Second reboot Required $($ComputerName)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
        $msg | Write-Verbose
        Restart-Computer -ComputerName $ComputerName -Wait -for Powershell -Force
        Start-Sleep -Seconds 30

        While (-Not (Test-DbaConnection -SQLInstance $ComputerName).ConnectSuccess) { Start-Sleep -Seconds 20 }
    }
    else {
        "Second reboot not Required $($ComputerName)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
        $msg | Write-Verbose
    }

    $ErrorActionPreference = $ErrorAction
}