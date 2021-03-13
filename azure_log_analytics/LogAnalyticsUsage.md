# Kusto - Log Analytics usage

### Usage by Solution (hourly)

```kusto
Usage
| where TimeGenerated > startofday(ago(1d))
| where IsBillable == true 
| summarize TotalVolumeGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1h), Solution
| render timechart;
```

<img src=".\images\usagebysolution.png">


```kusto
Usage
| where TimeGenerated > startofday(ago(1d))
| where IsBillable == true  
| summarize TotalVolumeGB = sum(Quantity) / 1000 by  bin(TimeGenerated, 1h), Solution
| render columnchart;
```
<img src=".\images\usagebysolutioncolumnchart.png">

### Usage by Data Type (hourly)
```kusto
Usage
| where TimeGenerated > startofday(ago(1d))
| where IsBillable == true 
| summarize TotalVolumeGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1h), DataType
| render timechart;
```

<img src=".\images\usagebydatatype.png">
