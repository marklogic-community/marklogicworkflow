xquery version "1.0-ml";

import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
let $workflow-id := wfu:new-workflow-id()
return (
  test:assert-meets-minimum-threshold(58, fn:string-length($workflow-id))
);


