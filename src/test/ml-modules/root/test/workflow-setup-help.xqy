xquery version "1.0-ml";
module namespace wsh = "http://marklogic.com/workflow/setup";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";
import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

declare function wsh:get-bpmn($filename as xs:string) {
  let $binary := test:get-modules-file(fn:concat("/test/bpmn/", $filename))
  let $bpmn-uri := fn:concat("/raw/bpmn/", $filename)
  let $text := xdmp:unquote(xdmp:quote($binary))
  return xdmp:document-insert($bpmn-uri, $text, xdmp:default-permissions(), xdmp:default-collections() )
};

declare function wsh:e2e-setup() {
  let $_modules-import := deploy:deploy()
  return uh:create-user("test-workflow-user", "test-workflow-user",
    ("workflow-role-unit-test", "rest-reader", "rest-writer"))
};

declare function wsh:get-file($uri as xs:string) {
  xdmp:eval('
    declare variable $uri as xs:string external;
    fn:doc($uri)
  ',
    (xs:QName('uri'), $uri),
    <options xmlns="xdmp:eval">
      <database>{xdmp:modules-database()}</database>
    </options>)
};
