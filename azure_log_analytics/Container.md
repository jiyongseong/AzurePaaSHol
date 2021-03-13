# Kusto - Container Log

### Container Log count by 10 minutes

```kusto
ContainerLog
| where TimeGenerated >= ago(12h)
| project TimeGenerated, ContainerID, LogEntry
| summarize count() by bin(TimeGenerated, 10m)
| render columnchart;
```

<img src=".\images\containerlogcountby10m.png">

### Container Log count by controller name
```kusto
let PodInfo=KubePodInventory
| distinct ContainerID,ControllerName;
ContainerLog
| where TimeGenerated >= ago(12h)
| join kind=leftouter PodInfo on ContainerID
| project TimeGenerated, ControllerName, LogEntry
| summarize count() by bin(TimeGenerated, 10m) , ControllerName
| render timechart;

let PodInfo=KubePodInventory
| distinct ContainerID,ControllerName;
ContainerLog
| where TimeGenerated >= ago(12h)
| join kind=leftouter PodInfo on ContainerID
| where ControllerName != "csi-secrets-store-csi-driver"
| project TimeGenerated, ControllerName, LogEntry;
```

<img src=".\images\containerlogcountbycontrollername.png">

### Container Log usage

```kusto
Usage
| where TimeGenerated > startofday(ago(1d))
| where IsBillable == true and DataType == 'ContainerLog'
| summarize TotalVolumeGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1h)
| render timechart;
```

<img src=".\images\containerlogusage.png">