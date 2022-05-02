Function Get-CoPhantomUserProcess {
       [CmdletBinding()]
       param(
              [String]$Environment = 'prod',
              [Parameter(Mandatory)]
              [String]$UserNum,
              [Parameter(Mandatory)]
              [String]$DateTime
       )

       $Date = Get-Date -Date $DateTime -Format 'MM/dd/yyyy'

       $Date | Write-Verbose

       $Query = @"
SELECT psdt.[PHANTOM_STATUS_DTL_ID] as 'Key'
       ,psdt.[PSDT_PHANTOM_STATUS]
       ,psdt.[PSDT_MNEMONIC]
       ,psdt.[PSDT_USER]
       ,'Duration' =
             CASE
             WHEN psdt.[PSDT_CRT_END_TIME] IS NOT NULL THEN cast((psdt.[PSDT_CRT_END_TIME] - psdt.[PSDT_CRT_START_TIME]) as time(0)) 
             ELSE cast( (getdate() - psdt.[PSDT_CRT_START_TIME]) as time(0))
             END
       ,cast(psdt.[PSDT_CRT_START_DATE] as date) AS 'PSDT_CRT_START_DATE'
       ,cast(psdt.[PSDT_CRT_START_TIME] as time(0)) AS 'PSDT_CRT_START_TIME'
       ,cast(psdt.[PSDT_CRT_END_DATE] as date) AS 'PSDT_CRT_END_DATE'
       ,cast(psdt.[PSDT_CRT_END_TIME] as time(0)) AS 'PSDT_CRT_END_TIME'
       ,psdt.[PSDT_CRT_COMO_NAME]
FROM [dbo].[PHANTOM_STATUS_DTL] as psdt with (noLock)
       FULL OUTER JOIN [dbo].[PHANTOM_STATUS] as ps with (noLock) ON psdt.[PSDT_PHANTOM_STATUS] = ps.[PHANTOM_STATUS_ID]
WHERE psdt.[PSDT_CRT_START_DATE] >= '$($Date)'
       AND psdt.[PSDT_CRT_COMO_NAME] LIKE '%[_]$($UserNum)'
AND psdt.[PSDT_CRT_END_DATE] IS NULL       
ORDER BY psdt.[PSDT_CRT_START_DATE] DESC, psdt.[PSDT_CRT_START_TIME] DESC, psdt.[PSDT_PHANTOM_STATUS]
"@


       $Query | Write-Verbose

       $Result = Invoke-SQLCmd -ServerInstance (Get-COSQLNode -Environment $Environment) -Database $Environment -Query $Query

       $Result | Write-Output
}