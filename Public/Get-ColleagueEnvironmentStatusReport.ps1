Function Get-ColleagueEnvironmentStatusReport {
    [CmdletBinding()]
    Param(
[Parameter(Mandatory)]
        [String]$Environment,
[Parameter(Mandatory)]
        [String[]]$EMail
    )

    $EDX = Get-AUEDXControl -Environment $Environment -ErrorAction SilentlyContinue
    $ProcessHandlerPID = Get-AUProcessHandlerPid -Environment $Environment
    $Listeners = Get-AUEnvironment -Environment $Environment

    If ($EDX.EDX_Control_TT_Flag -eq 'S') {
        $EDXStatus = 'Running'
        $EDXPid = $EDX.EDX_CONTROL_TT_PROCESS
    }
    else {
        $EDXStatus = 'Stopped'
        $EDXPid = '-'
    }

    If ($ProcessHandlerPID) {
        $ProcessHandlerStatus = 'Running'
    }
    else {
        $ProcessHandlerStatus = 'Stopped'
        $ProcessHandlerPID = '-'
    }

    $ColleagueServices = @(
        [PSCustomObject]@{
            Environment = 'n/a'
            Service     = 'LPR'
            Status      = (Get-AULPRListener).Status
            PID         = 'n/a'
        },
        [PSCustomObject]@{
            Environment = $Environment
            Service     = 'EDX'
            Status      = $EDXStatus
            PID         = $EdxPid
        },
        [PSCustomObject]@{
            Environment = $Environment
            Service     = 'Process Handler'
            Status      = $ProcessHandlerStatus
            PID         = $ProcessHandlerPID
        }
    )

    $ColleagueServicesHTML = $ColleagueServices | ConvertTo-Html -PreContent '<H2>Colleague Services</H2>'
    $ListenersHTML = $Listeners | ConvertTo-Html -PreContent '<H2>Colleague Listeners</H2>'
($ColleagueServicesHTML + $ListenersHTML) | Out-String | Send-AUMail -To $EMail -Subject "$($Environment): Maintenance Complete"
}
