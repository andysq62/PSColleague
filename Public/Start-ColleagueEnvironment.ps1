Function Start-ColleagueEnvironment {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [String[]]$Environment,
        [Switch]$IncludeLPR,
        [Switch]$IncludeProcessHandler,
        [Switch]$DisableUIECLimits
    )
    #    $DBListener = "${Environment}_DB_LISTENER"
    #    $APPListener = "${Environment}_APP_LISTENER"
    $ErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    $Environment | ForEach-Object {
        $E = $_
        $LogFile = "D:\Scripts\Logs\$($E).log"

        Try {
            If (($E -match 'prod') -And $IncludeLPR.IsPresent) {
                Start-ColleagueLPRListener
            }
            "$($E): Starting environment" | Write-CoLog -LogPath $LogFile
            Stop-CoEnvironment -Environment $E
            Start-Sleep -Seconds 10
            Start-CoEnvironment -Environment $E
            Start-Sleep -Seconds 10
            If (($E -NotMatch 'clean') -and ($E -notmatch 'glhist')) {
                "$($E): Starting EDX" | Write-CoLog -LogPath $LogFile
                Start-CoEDX -Environment $E
                If ($IncludeProcessHandler.IsPresent) {
                    "$($E): Starting Process Handler" | Write-CoLog -LogPath $LogFile
                    Start-CoProcessHandler -Environment $E
                }
                If ($DisableUIECLimits.IsPresent) {
                    Disable-CoUIECLimit -Environment $E
                }
            }
            "$($E): Start Complete" | Write-CoLog -LogPath $LogFile
        }
        Catch [Exception] {
            $_.Exception.Message | Write-CoLog -LogPath $LogFile
            Throw "$($E): Error starting environment listeners and services"
        }
    }

    $ErrorActionPreference = $ErrorAction
}