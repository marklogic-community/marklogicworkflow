## Testing

When installed via gradle, MarkLogic Workflow will also install the [ML Unit test harness](https://marklogic-community.github.io/marklogic-unit-test/)

Note that due to the asynchronous nature of the Content Processing Framework, some slower machines may report test failures as steps have taken time to complete.  Running tests individually or increasing the `xdmp:sleep` period may resolve failures.
