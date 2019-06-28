xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/test/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("022-email-test.bpmn", xdmp:database(), "/raw/bpmn/022-email-test.bpmn"),
  test:load-test-file("23-payload.xml", xdmp:database(), "/raw/data/23-payload.xml"),
  test:load-test-file("25-payload.xml", xdmp:database(), "/raw/data/25-payload.xml"),
  test:load-test-file("27-payload.xml", xdmp:database(), "/raw/data/27-payload.xml"),
  test:load-test-file("RejectedEmail.txt", xdmp:database(), "/raw/data/RejectedEmail.txt")
)
