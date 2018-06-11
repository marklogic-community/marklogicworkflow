xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";
import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

let $_modules-import := deploy:deploy()
let $_lock-fail-user := uh:create-user("test-workflow-user", "test-workflow-user", "test-workflow-user",
  ("workflow-role-unit-test", "rest-reader", "rest-writer") )

return (
  test:load-test-file("015-restapi-tests.bpmn", xdmp:database(), "/raw/bpmn/015-restapi-tests.bpmn"),
  test:load-test-file("06-payload.xml", xdmp:database(), "/raw/data/06-payload.xml"),
  test:load-test-file("09-payload.xml", xdmp:database(), "/raw/data/09-payload.xml"),
  test:load-test-file("11-payload.xml", xdmp:database(), "/raw/data/11-payload.xml"),
  test:load-test-file("12-payload.xml", xdmp:database(), "/raw/data/12-payload.xml"),
  test:load-test-file("13-payload.xml", xdmp:database(), "/raw/data/13-payload.xml")
)
