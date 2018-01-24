xquery version "1.0-ml";

(: 01 - start transaction1 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
cmrt:create-transaction ("/test/transaction1.xml");

(: 02 - create case1 (transaction1) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $filename := "case-post-payload.xml"
let $txid := cmrt:get-transaction-id("/test/transaction1.xml")
let $process := cmrt:create-case ($filename, $const:xml-options, $txid)
let $caseId := xs:string($process[2]/ext:createResponse/ext:caseId)
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-exists($caseId),
  xdmp:document-insert("/test/case1.xml", <test><caseId>{$caseId}</caseId></test>)
);

(: 03 - DB read case1 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseId := cmrt:get-case-id("/test/case1.xml")
return cmrt:fail-db-case-doc($caseId);

(: 04 - GET read case1 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case1.xml")
return cmrt:get-case-fail($caseId, $const:xml-options);

(: 05 - rollback transaction1 :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
let $txid := cmrt:get-transaction-id("/test/transaction1.xml")
return cmrt:rollback-transaction ($txid);

(: 06 - DB read case1 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseId := cmrt:get-case-id("/test/case1.xml")
return cmrt:fail-db-case-doc($caseId);

(: 07 - GET read case1 (fail) :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := cmrt:get-case-id("/test/case1.xml")
return cmrt:get-case-fail($caseId, $const:xml-options);
