xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/test/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("fork-within-fork.bpmn2", xdmp:database(), "/raw/bpmn/fork-within-fork.bpmn2"),
  test:load-test-file("payload.xml", xdmp:database(), "/raw/data/payload.xml")
)
