xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("fork-simple.bpmn2", xdmp:database(), "/raw/data/fork-simple.bpmn2"),
  test:load-test-file("fork-conditional.bpmn2", xdmp:database(), "/raw/data/fork-conditional.bpmn2"),
  test:load-test-file("fork-within-fork.bpmn2", xdmp:database(), "/raw/data/fork-within-fork.bpmn2") (: ,
  test:load-test-file("13-payload.xml", xdmp:database(), "/raw/data/13-payload.xml") :)
)
