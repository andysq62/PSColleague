Function ConvertFrom-UniDataDate {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [Int]$UniDataDate = (ConvertTo-UniDataDate -InputDate (Get-Date))
    )


    $BaseUniDataDate = @{
        Date = [DateTime]'12/31/1967'
        Days = 0
    }

(Get-Date $BaseUniDataDate.Date).AddDays($UniDataDate) | Write-Output
}