## Monitor logs with nozzle

- nozzle log
```
cf add-plugin-repo CF-Community http://plugins.cloudfoundry.org
cf install-plugin "Firehose Plugin" -r CF-Community
cf nozzle --debug
```

- Reference
  - http://operator-workshop.cloudfoundry.org/labs/monitoring/
