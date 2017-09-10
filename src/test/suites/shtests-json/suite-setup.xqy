xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("015-restapi-tests.bpmn", xdmp:database(), "/raw/data/015-restapi-tests.bpmn"),
  test:load-test-file("06-payload.xml", xdmp:database(), "/raw/data/06-payload.xml"),
  test:load-test-file("09-payload.xml", xdmp:database(), "/raw/data/09-payload.xml"),
  test:load-test-file("11-payload.xml", xdmp:database(), "/raw/data/11-payload.xml"),
  test:load-test-file("12-payload.xml", xdmp:database(), "/raw/data/11-payload.xml")
)
