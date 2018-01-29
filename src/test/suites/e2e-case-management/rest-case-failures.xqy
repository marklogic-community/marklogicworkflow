xquery version "1.0-ml";


(: 01 - GET case - no id :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/case")
let $response := xdmp:http-get($uri, $const:xml-options)
return (
  test:assert-equal('404', xs:string($response[1]/http:code)),
  test:assert-equal('Case not found', xs:string($response[1]/http:message)),
  test:assert-equal('caseId parameter is required', xs:string($response[2]/error:error-response/error:message))
);

(: 02 - GET non-existing case :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
cmrt:get-case-fail("12345", $const:xml-options);

(: 03 - attempt to insert a case with no data :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $uri := fn:concat( "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case" )
let $response := xdmp:http-post($uri, $const:xml-options)
return (
  test:assert-equal('405', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid input', xs:string($response[1]/http:message)),
  test:assert-equal('Nothing to insert', xs:string($response[2]/error:error-response/error:message))
);

(: 03 - attempt to insert a case that already exists :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $file := fn:doc("/raw/data/22345.xml")
let $uri := fn:concat( "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case" )
let $response := xdmp:http-post($uri, $const:xml-options, $file)
return (
  test:assert-equal('400', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid ID supplied', xs:string($response[1]/http:message)),
  test:assert-equal('caseId 22345 exists', xs:string($response[2]/error:error-response/error:message))
);

(: 04 - attempt to update a case with no caseId :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $file := fn:doc("/raw/data/case-put-payload.xml")
let $uri := fn:concat( "http://", $const:RESTHOST, ':', $const:RESTPORT, "/v1/resources/case" )
let $response := xdmp:http-put($uri, $const:xml-options, $file)
return (
  test:assert-equal('404', xs:string($response[1]/http:code)),
  test:assert-equal('Case not found', xs:string($response[1]/http:message)),
  test:assert-equal('caseId parameter is required', xs:string($response[2]/error:error-response/error:message))
);

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
  test:assert-equal('400', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid ID supplied', xs:string($response[1]/http:message)),
  test:assert-equal(fn:concat('caseId ', $caseId, ' not found'), xs:string($response[2]/error:error-response/error:message))
);

(: 100 - update a case with insufficient permissions :)
(:
currently a script - returns a nice "500" error; needs user in suite-setup & suite-teardown

xquery version "1.0-ml";

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";
let $options:=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>edwozere</username>
      <password>edwozere</password>
    </authentication>
    <headers>
      <content-type>application/xml</content-type>
      <accept>application/xml</accept>
    </headers>
  </options>
let $filename := "case-put-payload.xml"
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/case?rs:caseId=1")
let $fullpath := fn:concat("/raw/data/", $filename)
let $file := fn:doc($fullpath)
let $process := xdmp:http-put($uri, $options, $file)
let $caseId := xs:string($process[2]/ext:createResponse/ext:caseId)
return (
  ('200', xs:string($process[1]/http:code)),
  ('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  "exists",($caseId),
  $process
);

:)
