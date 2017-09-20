xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("015-restapi-tests.bpmn", xdmp:database(), "/raw/data/015-restapi-tests.bpmn"),
  test:load-test-file("06-payload.xml", xdmp:database(), "/raw/data/06-payload.xml"),
  test:load-test-file("13-payload.xml", xdmp:database(), "/raw/data/13-payload.xml"),
  test:load-test-file("14-payload.xml", xdmp:database(), "/raw/data/14-payload.xml")
)
