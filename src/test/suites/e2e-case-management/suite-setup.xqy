xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("01-payload.xml", xdmp:database(), "/raw/data/01-payload.xml"),
  test:load-test-file("03-payload.xml", xdmp:database(), "/raw/data/03-payload.xml")
)
