Function Get-IsSQLRunning {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, position = 0)]
        [String]$ComputerName
    )
    [Bool]$IsRunning = $True
    $Services = @('MSSQLSERVER', 'SQLSERVERAGENT')

    $Services | ForEach {
        $Status = (Get-DbaService -ComputerName $ComputerName -ServiceName $_ -ErrorAction SilentlyContinue).State
        "$($_) Status: $($Status)" | Write-Verbose

        If (($Status -ne 'Running') -or (!($Status))) {
            [Bool]$IsRunning = $false
            "Is Running: '$($IsRunning)'" | Write-Verbose
            break
        }
    }
    Return [Bool]$IsRunning
}