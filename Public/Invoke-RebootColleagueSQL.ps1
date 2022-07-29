Function Invoke-AURebootColleagueSQL {
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
    #    $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch

    If ((Get-DbaAvailabilityGroup -SqlInstance $E.Nodes.Node1 -AvailabilityGroup $E.Nodes.AvailabilityGroup).PrimaryReplica -ne $E.Nodes.Node1) {
        Throw "$($E.Name): $($E.Nodes.Node1) is not the primary replica"
    }
    Else {
        "$($E.Name): $($E.Nodes.Node1) is the primary replica" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
        $msg | Write-Verbose
    }

    "$($E.Name): Starting Failover to $($E.Nodes.Node2)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
    $msg | Write-Verbose
    Invoke-DbaAgFailover -SqlInstance $E.Nodes.Node2 -AvailabilityGroup $E.Nodes.AvailabilityGroup -EnableException -Confirm:$False
    Start-Sleep -Seconds 30

    Restart-AUSQLComputer -ComputerName $E.Nodes.Node1 -Database $E.Name

    #    $StopWatch.Reset()
    Start-Sleep -Seconds 20
    "$($E.Name): Now Failover to $($E.Nodes.Node1)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
    $msg | Write-Verbose
    Invoke-DbaAgFailover -SqlInstance $E.Nodes.Node1 -AvailabilityGroup $E.Nodes.AvailabilityGroup -EnableException -Confirm:$False
    Start-Sleep -Seconds 30

    Restart-AUSQLComputer -ComputerName $E.Nodes.Node2 -Database $E.Name


    "$($E.Name): Now rebooting $($E.Nodes.Node3), $($E.Nodes.Node4) and $($E.AppServer)" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
    $msg | Write-Verbose
    If (($E.Name -eq 'prod') -or ($E.Name -eq 'test')) {
        Restart-Computer -ComputerName $E.Nodes.Node3, $E.Nodes.Node4, $E.AppServer -Wait -For Powershell -Force
    }
    else {
        Restart-Computer -ComputerName $E.AppServer -Wait -For Powershell -Force
    }


    "$($E.Name): End Reboot of Colleague Servers" | Tee-Object -Variable msg | Write-AULog -LogPath $LogFile
    $msg | Write-Verbose
    $ErrorActionPreference = $ErrorAction

}