# Kusto - Common

### Convert UTC to KST
```kusto
Usage
| where TimeGenerated >= ago(14d)
| project TimeGenerated, TimeGeneratedKST=datetime_add('hour', 9, TimeGenerated), SourceSystem, Quantity
```

<img src=".\images\convertutc2kst.png">


### Case
```kusto
ContainerLog
| where TimeGenerated >= ago(1d)
| where LogEntrySource == 'stderr' 
| extend log = case(LogEntry contains "connection.go:153] Connecting to unix:///csi/csi.sock", "connection.go:153] Connecting to unix:///csi/csi.sock",
LogEntry contains "secretproviderclasspodstatus_controller.go:183] \"reconcile started\"", "secretproviderclasspodstatus_controller.go:183] \"reconcile started\"",
LogEntry contains "secretproviderclasspodstatus_controller.go:329] \"reconcile complete\"", "secretproviderclasspodstatus_controller.go:329] \"reconcile complete\"",
  LogEntry)
| summarize count() by log
```