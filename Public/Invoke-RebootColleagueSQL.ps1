Function Invoke-RebootColleagueSQL {
    [CmdletBinding()]
    param(
        [ValidateSet('clean', 'development', 'test', 'prod')]
        [String]$Environment,
        [String]$Path = 'D:\Scripts\ColleagueMaintenanceAutomation'
    )

    $ErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    $LogFile = "D:\Scripts\Logs\$($Environment).log"
    $JSON = Join-Path -Path $Path -ChildPath 'ColleagueMaintenance.json'

    If (!(Test-Path -Path $JSON)) {
        Throw "Cannot find configuration file: ${JSON}"
    }

    $Environments = Get-Content -Path $JSON | ConvertFrom-Json
    $E = $Environments | Where-Object { $_.Name -eq "$Environment" }
    #     $RebootTimeOut = 7200
    $DBTimeOut = 120
    $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch

    If ((Get-DbaAvailabilityGroup -SqlInstance $E.Nodes.Node1 -AvailabilityGroup $E.Nodes.AvailabilityGroup).PrimaryReplica -ne $E.Nodes.Node1) {
        Throw "$($E.Name): $($E.Nodes.Node1) is not the primary replica"
    }
    Else {
        "$($E.Name): $($E.Nodes.Node1) is the primary replica" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
        $msg | Write-Verbose
    }

    "$($E.Name): Starting Failover to $($E.Nodes.Node2)" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    Invoke-DbaAgFailover -SqlInstance $E.Nodes.Node2 -AvailabilityGroup $E.Nodes.AvailabilityGroup -EnableException -Confirm:$False
    Start-Sleep -Seconds 5
    If ((Get-DbaAvailabilityGroup -SqlInstance $E.Nodes.Node2 -AvailabilityGroup $E.Nodes.AvailabilityGroup).PrimaryReplica -ne $E.Nodes.Node2) {
        Throw "$($E.Name): $($E.Nodes.Node2) is not the primary replica"
    }
    Else {
        "$($E.Name): $($E.Nodes.Node2) is the primary replica" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
        $msg | Write-Verbose
    }

    "$($E.Name): Now rebooting $($E.Nodes.Node1)" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    Restart-Computer -ComputerName $E.Nodes.Node1 -Wait -Force
    While (-Not (Get-IsSQLRunning -ComputerName $E.Nodes.Node1)) { Start-Sleep -Seconds 5 }
    $StopWatch.Start()
    While ((!((Get-DbaDatabase -SqlInstance $E.Nodes.Node1 -Database $E.Name -ErrorAction SilentlyContinue).IsAccessible)) -and ($StopWatch.Elapsed.TotalSeconds -lt $DBTimeOut)) {
        Start-Sleep -Seconds 5
    }
    If ($StopWatch.Elapsed.TotalSeconds -ge $DBTimeOut) {
        Throw "Cannot reach $($E.Name) or timed out after failover attempt"
    }
    $StopWatch.Stop()
    $StopWatch.Reset()

    "$($E.Name): Now Failover to $($E.Nodes.Node1)" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    Invoke-DbaAgFailover -SqlInstance $E.Nodes.Node1 -AvailabilityGroup $E.Nodes.AvailabilityGroup -EnableException -Confirm:$False
    Start-Sleep -Seconds 5
    If ((Get-DbaAvailabilityGroup -SqlInstance $E.Nodes.Node1 -AvailabilityGroup $E.Nodes.AvailabilityGroup).PrimaryReplica -ne $E.Nodes.Node1) {
        Throw "$($E.Name): $($E.Nodes.Node1) is not the primary replica"
    }
    Else {
        "$($E.Name): $($E.Nodes.Node1) is the primary replica" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
        $msg | Write-Verbose
    }

    "$($E.Name): Now Rebooting $($E.Nodes.Node2)" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    Restart-Computer -ComputerName $E.Nodes.Node2 -Wait -Force
    While (-Not (Get-IsSQLRunning -ComputerName $E.Nodes.Node2)) { Start-Sleep -Seconds 5 }
    $StopWatch.Start()
    While ((!((Get-DbaDatabase -SqlInstance $E.Nodes.Node2 -Database $E.Name -ErrorAction SilentlyContinue).IsAccessible)) -and ($StopWatch.Elapsed.TotalSeconds -lt $DBTimeOut)) {
        Start-Sleep -Seconds 5
    }
    If ($StopWatch.Elapsed.TotalSeconds -ge $DBTimeOut) {
        Throw "Cannot reach $($E.Nodes.Node2) $($E.Name) or timed out after failover attempt"
    }
    $StopWatch.Stop()

    "$($E.Name): Now rebooting $($E.Nodes.Node3), $($E.Nodes.Node4) and $($E.AppServer)" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    Restart-Computer -ComputerName $E.Nodes.Node3, $E.Nodes.Node4, $E.AppServer -Wait -Force


    "$($E.Name): End Reboot of Colleague Servers" | Tee-Object -Variable msg | Write-CoLog -LogPath $LogFile
    $msg | Write-Verbose
    $ErrorActionPreference = $ErrorAction

}