xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";
import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

let $_modules-import := deploy:deploy() (:
let $_lock-fail-user := uh:create-user("test-workflow-user", "test-workflow-user", "test-workflow-user",
  ("workflow-role-unit-test", "rest-reader", "rest-writer") ) :)

let $uri := "/test/suites/workflow-util/test-data/process-properties.xml"
let $properties-doc := xdmp:eval('
    declare variable $uri as xs:string external;
    fn:doc($uri)
  ',
  (xs:QName('uri'), $uri),
  <options xmlns="xdmp:eval">
    <database>{xdmp:modules-database()}</database>
  </options>)
let $properties := $properties-doc/prop:properties/*
return (
  test:load-test-file("process-main.xml", xdmp:database(), "/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml"),
  xdmp:document-set-collections("/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml", "http://marklogic.com/workflow/processes"),
  xdmp:document-set-properties("/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml", $properties)
  ,
  test:load-test-file("pipeline-1.xml", xdmp:database(), "http://marklogic.com/cpf/pipelines/16777465620663218130.xml"),
  xdmp:document-set-collections("http://marklogic.com/cpf/pipelines/16777465620663218130.xml", "http://marklogic.com/cpf/pipelines"),

  test:load-test-file("pipeline-2.xml", xdmp:database(), "http://marklogic.com/cpf/pipelines/9065659835217097521.xml"),
  xdmp:document-set-collections("http://marklogic.com/cpf/pipelines/9065659835217097521.xml", "http://marklogic.com/cpf/pipelines"),

  test:load-test-file("pipeline-3.xml", xdmp:database(), "http://marklogic.com/cpf/pipelines/8285677651365931589.xml"),
  xdmp:document-set-collections("http://marklogic.com/cpf/pipelines/8285677651365931589.xml", "http://marklogic.com/cpf/pipelines")
)
(:
  test:load-test-file("015-restapi-tests.bpmn", xdmp:database(), "/raw/data/015-restapi-tests.bpmn"),
  test:load-test-file("06-payload.xml", xdmp:database(), "/raw/data/06-payload.xml"),
  test:load-test-file("09-payload.xml", xdmp:database(), "/raw/data/09-payload.xml"),
  test:load-test-file("11-payload.xml", xdmp:database(), "/raw/data/11-payload.xml"),
  test:load-test-file("12-payload.xml", xdmp:database(), "/raw/data/12-payload.xml"),
  test:load-test-file("13-payload.xml", xdmp:database(), "/raw/data/13-payload.xml")
:)
