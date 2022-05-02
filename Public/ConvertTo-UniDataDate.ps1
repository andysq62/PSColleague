Function ConvertTo-UniDataDate {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [DateTime]$InputDate = (Get-Date)
    )

    $BaseUniDataDate = @{
        Date = [DateTime]'12/31/1967'
        Days = 0
    }


(New-TimeSpan -Start $BaseUniDataDate.Date -End $InputDate).Days | Write-Output
}