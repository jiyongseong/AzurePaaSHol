# Kusto - Application Gateway

### Count by http status
```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"  
| where TimeGenerated >= ago(14d)
| summarize count() by tostring(httpStatus_d)
| render piechart;
```

<img src=".\images\countbyhttpstatus.png">

```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and httpStatus_d > 399
| where TimeGenerated >= ago(12h)
| summarize count() by bin(TimeGenerated, 1h), tostring(httpStatus_d)
| render timechart;
```

<img src=".\images\countbyhttpstatustimechart.png">