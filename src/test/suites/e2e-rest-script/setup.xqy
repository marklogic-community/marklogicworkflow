xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("script-test.bpmn", xdmp:database(), "/raw/bpmn/script-test.bpmn"),
  test:load-test-file("23-payload.xml", xdmp:database(), "/raw/data/23-payload.xml"),
  test:load-test-file("25-payload.xml", xdmp:database(), "/raw/data/25-payload.xml"),
  test:load-test-file("27-payload.xml", xdmp:database(), "/raw/data/27-payload.xml")
)
