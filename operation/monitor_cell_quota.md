## Editing cf cell quota monitor
- curl http://cell-ip:1800/state
- cell 의 사용량은 cpu    memory        disk 의 값은 cf push 시 요청한 값을 기준으로 산정
- 참고 rep cell status
```
# 참고 Rep로 부터 리턴되는 객체 정보(repClientFactory.CreateClient(cp.RepAddress).State())
type CellState struct {
       RootFSProviders        RootFSProviders
       AvailableResources     Resources
       TotalResources         Resources
       LRPs                   []LRP
       Tasks                  []Task
       StartingContainerCount int
       Zone                   string
       Evacuating             bool
       VolumeDrivers          []string
}

type Resources struct {
       MemoryMB   int32
       DiskMB     int32
       Containers int32
}
```

Reference
- https://discuss.pivotal.io/hc/en-us/articles/221251847-Starting-or-staging-an-application-results-in-an-InsufficientResources-error
- https://discuss.pivotal.io/hc/en-us/articles/221251847-Starting-or-staging-an-application-results-in-an-InsufficientResources-error
