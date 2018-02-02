xquery version "1.0-ml";
(: 01 - POST caseactivity 1 :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <wfc:activity id="activity1" template-id="atemplate1">
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=testphase")
let $response := xdmp:http-post($uri, $const:xml-options, $activity)
return (
  test:assert-equal('200',       xs:string($response[1]/http:code)),
  test:assert-equal('OK',        xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',   xs:string($response[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('activity1', xs:string($response[2]/ext:createResponse/ext:caseactivityId))
);

(: 02 - check case updated & new activity created :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $response := cmrt:get-case("22345", $const:xml-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="testphase"]/wfc:activities/wfc:activity[@id="activity1"]),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="testphase"]/wfc:activities/wfc:activity[@id="activity2"])
);

(: 03 - POST caseactivity 2 :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <wfc:activity id="activity2" template-id="atemplate1">
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=testphase")
let $response := xdmp:http-post($uri, $const:xml-options, $activity)
return (
  test:assert-equal('200',       xs:string($response[1]/http:code)),
  test:assert-equal('OK',        xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',   xs:string($response[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('activity2', xs:string($response[2]/ext:createResponse/ext:caseactivityId))
);

(: 04 - check case updated activity updated :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $response := cmrt:get-case("22345", $const:xml-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="testphase"]/wfc:activities/wfc:activity[@id="activity1"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="testphase"]/wfc:activities/wfc:activity[@id="activity2"])
);

(: 05 - POST caseactivity 2 again - should fail :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <wfc:activity id="activity2" template-id="atemplate1">
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=testphase")
let $response := xdmp:http-post($uri, $const:xml-options, $activity)
return ( (: TODO - this should fail :)
  test:assert-equal('400', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid ID supplied', xs:string($response[1]/http:message)),
  test:assert-equal('activityId activity2 exists', xs:string($response[2]/error:error-response/error:message))
);

