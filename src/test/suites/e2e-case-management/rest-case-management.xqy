xquery version "1.0-ml";

(: 01 to 07 CREATE CASE :)

(: 01 - start transaction2 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction2.xml");

(: 02 - create case2 (transaction2) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $filename := "case-post-payload.xml"
let $txid := cmrt:get-transaction-id("/test/transaction2.xml")
let $process := cmrt:create-case ($filename, $const:xml-options, $txid)
let $caseId := xs:string($process[2]/ext:createResponse/ext:caseId)
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-exists($caseId),
  xdmp:document-insert("/test/case2.xml", <test><caseId>{$caseId}</caseId></test>)
);

(: 03 - DB read case2 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:fail-db-case-doc($caseId);

(: 04 - GET read case2 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:get-case-fail($caseId, $const:xml-options)
;

(: 05 - commit transaction2 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction2.xml")
return cmrt:commit-transaction ($txid);

(: 06 - DB read case2 (pass) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $_pause := xdmp:sleep(5000)
let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:pass-db-case-doc($caseId);

(: 07 - GET read case2 (pass) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $const:xml-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase/wfc:activities/wfc:activity)
);

(: 08-10 TBD... :)

(: 11 to 16 UPDATE CASE :)

(: 11 - start transaction3 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction3.xml");

(: 12 - update case2 (transaction3) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $filename := "case-put-payload.xml"
let $txid := cmrt:get-transaction-id("/test/transaction3.xml")
let $process := cmrt:update-case ($caseId, $filename, $const:xml-options, $txid)
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:updateResponse/ext:outcome))
);

(: 13 - GET read case2 (not updated) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $const:xml-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase/wfc:activities/wfc:activity)
);

(: 14 - commit transaction3 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction3.xml")
return cmrt:commit-transaction ($txid);

(: 15 - GET read case2 (updated) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $const:xml-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="phase1"]/wfc:activities/wfc:activity[@id="activity1"])
);

(: 16 - attempt to update a case with no data :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case?rs:caseId=", $caseId)
let $response := xdmp:http-put($uri, $const:xml-options)

return (
  test:assert-equal('405', xs:string($response[1]/http:code)),
  test:assert-equal('Validation exception', xs:string($response[1]/http:message)),
  test:assert-equal('Nothing to update', xs:string($response[2]/error:error-response/error:message))
);

(: 17-20 TBD... :)

