xquery version "1.0-ml";
(: 01 - POST caseactivity 1 :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=22345-phase1")
let $response := xdmp:http-post($uri, $cmrt:user-one-options, $activity)
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

let $response := cmrt:get-case("22345", $cmrt:user-one-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity1"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit/wfc:description[xs:string(.)="Case Activity activity1 Inserted"]),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"])
);

(: 03 - POST caseactivity 2 :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=22345-phase1")
let $response := xdmp:http-post($uri, $cmrt:user-one-options, $activity)
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

let $response := cmrt:get-case("22345", $cmrt:user-one-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity1"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit/wfc:description[xs:string(.)="Case Activity activity1 Inserted"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit/wfc:description[xs:string(.)="Case Activity activity2 Inserted"])
);

(: 05 - POST caseactivity 2 again - should fail :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
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
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=22345-phase1")
let $response := xdmp:http-post($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('400', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid ID supplied', xs:string($response[1]/http:message)),
  test:assert-equal('activityId activity2 exists', xs:string($response[2]/error:error-response/error:message))
);

(: 05 - POST caseactivity 3 as user 2 - fails as user cannot see the document :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <wfc:activity id="activity3" template-id="atemplate1">
    <wfc:data>
      <wfc:name>Contact Customer Yet Again</wfc:name>
      <wfc:public-name>Contact Customer Yet Again</wfc:public-name>
    </wfc:data>
    <wfc:status>NotActive</wfc:status>
    <wfc:description>string</wfc:description>
    <wfc:notes>string</wfc:notes>
  </wfc:activity>
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:caseId=22345&amp;rs:phaseId=22345-phase1")
let $response := xdmp:http-post($uri, $cmrt:user-two-options, $activity)
return (
  test:assert-equal('400', xs:string($response[1]/http:code)),
  test:assert-equal('Invalid ID supplied', xs:string($response[1]/http:message)),
  test:assert-equal('caseId 22345 not found', xs:string($response[2]/error:error-response/error:message))
);

(: 06 - PUT caseactivity 2 - update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <wfc:activity id="activity2" template-id="atemplate1">
    <wfc:status>Active</wfc:status>
    <wfc:notes>changed to active</wfc:notes>
  </wfc:activity>
let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:activityId=activity2")
let $response := xdmp:http-put($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('200',       xs:string($response[1]/http:code)),
  test:assert-equal('OK',        xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',   xs:string($response[2]/ext:updateResponse/ext:outcome))
);

(: 07 - check case updated activity updated :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $response := cmrt:get-case("22345", $cmrt:user-one-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit/wfc:description[xs:string(.)="Case Activity activity1 Inserted"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit/wfc:description[xs:string(.)="Case Activity activity2 Inserted"]),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"]),
  test:assert-equal('Active', xs:string($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"]/wfc:status)),
  test:assert-equal('changed to active', xs:string($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="22345-phase1"]/wfc:activities/wfc:activity[@id="activity2"]/wfc:notes))
);
