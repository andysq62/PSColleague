Function Stop-ColleagueEnvironment {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [String[]]$Environment,
        [parameter(Position = 1)]
        [String[]]$EMail = (Get-COEmail -EMail 'ProdFiles')
    )
    $ErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    $Environment | ForEach-Object {
        $E = $_
        $LogFile = "D:\Scripts\Logs\$($E).log"
        $DBListenerName = "$($E)_DB_LISTENER"

        Try {
            If ($E -match 'prod') {
                "$($E): Stopping LPR" | Write-CoLog -LogPath $LogFile
                Stop-CoLPRListener
            }
            If (($E -Notmatch 'clean') -and ($E -notmatch 'glhist')) {
                Enable-CoUIECLimit -Environment $E
                "$($E): Stopping EDX" | Write-CoLog -LogPath $LogFile
                Stop-CoEDX -Environment $E
                Start-Sleep -Seconds 10
            }
            "$($E): Stopping environment listeners" | Write-CoLog -LogPath $LogFile
            Stop-CoEnvironment -Environment $E
            Start-ColleagueListener -Environment $E -Name $DBListenerName
            Start-Sleep -Seconds 5
            If ((Get-ColleagueListener -Environment $E -Name $DBListenerName).Status.Value -match 'Running') {
                "$($E): Clearing WWW Files" | Write-CoLog -LogPath $LogFile
                Clear-CoWWWFiles -Environment $E
            }
            else {
                "$($E): DB Listener is not running, cannot clear WWW Files" | Write-CoLog -LogPath $LogFile
            }
            Stop-ColleagueListener -Environment $E -Name $DBListenerName
            "$($E): End Shutdown" | Write-CoLog -LogPath $LogFile
        }
        Catch [Exception] {
            $_.Exception.Message | Write-CoLog -LogPath $LogFile
            Throw "$($E): Error stopping Colleague environment"
        }
    }  # End loop through environments

    $ErrorActionPreference = $ErrorAction
} # End Function