xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

(: import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy"; :)
import module namespace wsh = "http://marklogic.com/workflow/setup" at "/test/workflow-setup-help.xqy";

let $_modules-import := deploy:deploy()
(:
let $_lock-fail-user := uh:create-user("test-workflow-user", "test-workflow-user", "test-workflow-user",
  ("workflow-role-unit-test", "rest-reader", "rest-writer") ) :)

let $properties := wsh:get-file("/test/suites/workflow-util/test-data/process-properties.xml")/prop:properties/*
  (: let $properties2 := wsh:get-file("/test/suites/workflow-util/test-data/process-properties-2.xml")/prop:properties/* :)
return (
  test:load-test-file("process-main.xml", xdmp:database(), "/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml"),
  xdmp:document-set-collections("/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml", "http://marklogic.com/workflow/processes"),
  xdmp:document-set-properties("/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml", $properties)
)

