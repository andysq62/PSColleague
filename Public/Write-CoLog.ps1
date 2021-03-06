Function Write-CoLog {
  [CmdletBinding()]
  Param (
    [Parameter(Position = 0)]
    [string]$LogPath = 'D:\Scripts\Logs\Colleague.log',
    [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
    [string]$Message
  )

  Process {

    If (!(Test-Path -Path $LogPath) ) {
      $null = New-Item -Path $LogPath –ItemType File
    }

    $Message = "[$([DateTime]::Now)] $env:ComputerName $Message"

    Add-Content -Path $LogPath -Value $Message
  }
}
