xquery version "1.0-ml";


(: 01 - GET case - no id :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/case")
let $response := xdmp:http-get($uri, $const:xml-options)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-equal('caseId parameter is required', xs:string($response[2]/ext:readResponse/ext:details))
);

(: 02 - GET non-existing case :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
cmrt:get-case-fail("12345", $const:xml-options);

(: 03 - attempt to insert a case with no data :)

(: 04 - attempt to update a case with no caseId : )
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $file := fn:doc("/raw/data/case-put-payload.xml")
let $process := cmrt:update-case ($caseId, $filename, $const:xml-options, ())
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case")
let $response := xdmp:http-put($uri, $options, $file)
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-equal('caseId parameter is required', xs:string($response[2]/ext:readResponse/ext:details))
); :)

(: 05 - attempt to update a case which does not exist :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $caseId := "12345"
let $filename := "case-put-payload.xml"
let $response := cmrt:update-case ($caseId, $filename, $const:xml-options, ())
return (
  test:assert-equal('200', xs:string($response[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($response[2]/ext:readResponse/ext:outcome)),
  test:assert-equal(fn:concat('caseId ', $caseId, ' not found'), xs:string($response[2]/ext:readResponse/ext:details))
);
