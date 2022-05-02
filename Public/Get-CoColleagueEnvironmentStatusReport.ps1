Function Get-CoColleagueEnvironmentStatusReport {
    [CmdletBinding()]
    Param(
        [String]$Environment
    )

    $EDX = Get-CoEDXControl -Environment $Environment
    $ProcessHandlerPID = Get-CoProcessHandlerPid -Environment $Environment
    $Listeners = Get-ColleagueEnvironment -Environment $Environment

    If ($EDX.EDX_Control_TT_Flag -eq 'S') {
        $EDXStatus = 'Running'
    }
    else {
        $EDXStatus = 'Stopped'
    }

    If ($ProcessHandlerPID) {
        $ProcessHandlerStatus = 'Running'
    }
    else {
        $ProcessHandlerStatus = 'Stopped'
    }

    $ColleagueServices = @(
        [PSCustomObject]@{
            Environment = $Environment
            Service     = 'EDX'
            Status      = $EDXStatus
        },
        [PSCustomObject]@{
            Environment = $Environment
            Service     = 'Process Handler'
            Status      = $ProcessHandlerStatus
        }
    )

    $ColleagueServicesHTML = $ColleagueServices | ConvertTo-Html -PreContent '<H2>Colleague Services</H2>'
    $ListenersHTML = $Listeners | ConvertTo-Html -PreContent '<H2>Colleague Listeners</H2>'
($ColleagueServicesHTML + $ListenersHTML) | Out-String | Send-CoMail -To squires@american.edu -Subject "$($Environment): Reboots/Maintenance Complete"
}
