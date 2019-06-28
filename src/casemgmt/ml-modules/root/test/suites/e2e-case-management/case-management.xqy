xquery version "1.0-ml";

(: 01 to 07 CREATE CASE :)

(: 01 - start transaction2 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction2.xml");

(: 02 - create case2 (transaction2) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $filename := "case-post-payload.xml"
let $txid := cmrt:get-transaction-id("/test/transaction2.xml")
let $process := cmrt:create-case ($filename, $cmrt:user-one-options, $txid)
let $caseId := xs:string($process[2]/ext:createResponse/ext:caseId)
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-exists($caseId),
  xdmp:document-insert("/test/case2.xml", <test><caseId>{$caseId}</caseId></test>)
);

(: 03 - DB read case2 (fail) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:fail-db-case-doc($caseId);

(: 04 - GET read case2 (fail) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";

let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:get-case-fail($caseId, $cmrt:user-one-options)
;

(: 05 - commit transaction2 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction2.xml")
return cmrt:commit-transaction ($txid);

(: 06 - DB read case2 (pass) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
let $_pause := xdmp:sleep(5000)
let $caseId := cmrt:get-case-id("/test/case2.xml")
return cmrt:pass-db-case-doc($caseId);

(: 07 - GET read case2 (pass) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $cmrt:user-one-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase/wfc:activities/wfc:activity)
);

(: 08-10 TBD... :)

(: 11 to 16 UPDATE CASE :)

(: 11 - start transaction3 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction3.xml");

(: 12 - update case2 (transaction3) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $filename := "case-put-payload.xml"
let $txid := cmrt:get-transaction-id("/test/transaction3.xml")
let $process := cmrt:update-case ($caseId, $filename, $cmrt:user-one-options, $txid)
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:updateResponse/ext:outcome))
);

(: 13 - GET read case2 (not updated) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $cmrt:user-one-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase/wfc:activities/wfc:activity)
);

(: 14 - commit transaction3 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction3.xml")
return cmrt:commit-transaction ($txid);

(: 15 - GET read case2 (updated) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $cmrt:user-one-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="phase1"]/wfc:activities/wfc:activity[@id="activity1"])
);

(: 16 - attempt to update a case with no data :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case?rs:caseId=", $caseId)
let $response := xdmp:http-put($uri, $cmrt:user-one-options)

return (
  test:assert-equal('405',               xs:string($response[1]/http:code)),
  test:assert-equal('Invalid input',     xs:string($response[1]/http:message)),
  test:assert-equal('Nothing to update', xs:string($response[2]/error:error-response/error:message))
);

(: 21 to 26 INSERT CASE ACTIVITY :)

(: 21 - start transaction4 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction4.xml");

(: 22 - new activity 1 :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $txid := cmrt:get-transaction-id("/test/transaction4.xml")
let $activity :=
  <wfc:activity id="phase2activity1" template-id="atemplate1">
    <wfc:data>
      <wfc:name>Contact Customer</wfc:name>
      <wfc:public-name>Contact Customer</wfc:public-name>
    </wfc:data>
    <wfc:status>NotActive</wfc:status>
    <wfc:description>string</wfc:description>
    <wfc:notes>string</wfc:notes>
  </wfc:activity>
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:caseId=", $caseId, "&amp;rs:phaseId=phase2&amp;txid=", $txid)
let $response := xdmp:http-post($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('200',             xs:string($response[1]/http:code)),
  test:assert-equal('OK',              xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',         xs:string($response[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('phase2activity1', xs:string($response[2]/ext:createResponse/ext:caseactivityId))
);

(: 23 - GET read case2 (not updated) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $cmrt:user-one-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="phase2"]/wfc:activities/wfc:activity[@id="phase2activity1"])
);

(: 24 - new activity 2 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $txid := cmrt:get-transaction-id("/test/transaction4.xml")
let $activity :=
  <wfc:activity id="phase2activity2" template-id="atemplate1">
    <wfc:data>
      <wfc:name>Contact Customer Again</wfc:name>
      <wfc:public-name>Contact Customer Again</wfc:public-name>
    </wfc:data>
    <wfc:status>NotActive</wfc:status>
    <wfc:description>string</wfc:description>
    <wfc:notes>string</wfc:notes>
  </wfc:activity>
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:caseId=", $caseId, "&amp;rs:phaseId=phase2&amp;txid=", $txid)
let $response := xdmp:http-post($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('200',       xs:string($response[1]/http:code)),
  test:assert-equal('OK',        xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',   xs:string($response[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('phase2activity2', xs:string($response[2]/ext:createResponse/ext:caseactivityId))
);

(: 25 - commit transaction4 :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction4.xml")
return cmrt:commit-transaction ($txid);

(: 26 - GET read case2 (updated) :)
import module namespace cmrt="http://marklogic.com/test/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case2.xml")
let $response := cmrt:get-case($caseId, $cmrt:user-one-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($response[2]/ext:readResponse/wfc:case),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="phase2"]/wfc:activities/wfc:activity[@id="phase2activity1"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="phase2"]/wfc:activities/wfc:activity[@id="phase2activity2"])
);

