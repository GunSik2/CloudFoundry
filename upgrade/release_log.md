# important changes

## Diego
- cf[v240](https://bosh.io/releases/github.com/cloudfoundry/cf-release?version=240) diego[v0.1481.0](https://github.com/cloudfoundry/diego-release/releases/tag/v0.1481.0) 
  - Diego no longer contains a separate 'converger' component. Instead, the active BBS server runs Task and LRP convergence periodically and in reaction to a cell presence disappearing.
