xquery version "1.0-ml";
(: 01 - PATCH activity 1 :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";
declare namespace http = "xdmp:http";

let $activity :=
  <rapi:patch xmlns:c="http://marklogic.com/workflow/case">
    <rapi:insert context="/c:activity" position="last-child">
      <c:insert1/>
    </rapi:insert>
    <rapi:insert context="/c:activity" position="last-child">
      <c:insert2/>
    </rapi:insert>
    <rapi:replace select="/c:activity/c:data/c:name">
      <c:name>Contact Customer Update</c:name>
    </rapi:replace>
    <rapi:delete select="//c:something-to-remove/c:remove-this"/>
  </rapi:patch>

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:activityId=32345-activity1&amp;rs:patch=true")
let $response := xdmp:http-put($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('200',       xs:string($response[1]/http:code)),
  test:assert-equal('OK',        xs:string($response[1]/http:message)),
  test:assert-equal('SUCCESS',   xs:string($response[2]/ext:updateResponse/ext:outcome)),
  (: TODO - test output :)
  test:assert-exists($response[2]/ext:updateResponse/ext:patchOutcome)
);

(: 02 - check activity updated & new audit record created :)
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

let $response := cmrt:get-case("32345", $cmrt:user-one-options)
return (
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="32345-phase1"]/wfc:activities/wfc:activity[@id="32345-activity1"]/wfc:insert1),
  test:assert-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="32345-phase1"]/wfc:activities/wfc:activity[@id="32345-activity1"]/wfc:insert2),
  test:assert-equal("Contact Customer Update",xs:string($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="32345-phase1"]/wfc:activities/wfc:activity[@id="32345-activity1"]/wfc:data/wfc:name)),
  test:assert-not-exists($response[2]/ext:readResponse/wfc:case/wfc:phases/wfc:phase[@id="32345-phase1"]/wfc:activities/wfc:activity[@id="32345-activity1"]/wfc:data/wfc:something-to-remove/wfc:remove-this),
  test:assert-equal("Case Activity 32345-activity1 Patched", xs:string($response[2]/ext:readResponse/wfc:case/wfc:audit-trail/wfc:audit[2]/wfc:description))
);

(: 03 - attempt to patch things that don't exist :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace wfc   = "http://marklogic.com/workflow/case";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http  = "xdmp:http";

let $activity :=
  <rapi:patch xmlns:c="http://marklogic.com/workflow/case">
    <rapi:insert context="/c:activity/c:no-insert-position" position="last-child">
      <c:insert1/>
    </rapi:insert>
  </rapi:patch>

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:activityId=32345-activity1&amp;rs:patch=true")
let $response := xdmp:http-put($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('405',       xs:string($response[1]/http:code)),
  test:assert-equal(
    'Invalid content patch for activity 32345-activity1',
    xs:string($response[1]/http:message)),
  test:assert-equal(
    'invalid path: /c:case/c:phases/c:phase/c:activities/c:activity[@id="32345-activity1"]/c:no-insert-position',
    xs:string($response[2]/error:error-response/error:message))
);

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $activity :=
  <rapi:patch xmlns:c="http://marklogic.com/workflow/case">
    <rapi:replace select="/c:activity/c:data/c:irreplaceable">
      <c:name>Contact Customer Update</c:name>
    </rapi:replace>
  </rapi:patch>

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:activityId=32345-activity1&amp;rs:patch=true")
let $response := xdmp:http-put($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('405',       xs:string($response[1]/http:code)),
  test:assert-equal(
    'Invalid content patch for activity 32345-activity1',
    xs:string($response[1]/http:message)),
  test:assert-equal(
    'invalid path: /c:case/c:phases/c:phase/c:activities/c:activity[@id="32345-activity1"]/c:data/c:irreplaceable',
    xs:string($response[2]/error:error-response/error:message))
);

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace cmrt="http://marklogic.com/roxy/casemanagement/rest-tests" at "/test/casemgmt-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace wfc = "http://marklogic.com/workflow/case";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace http = "xdmp:http";

let $activity :=
  <rapi:patch xmlns:c="http://marklogic.com/workflow/case">
    <rapi:delete select="/c:activity/c:something-to-remove/c:remove-this"/>
  </rapi:patch>

let $uri := fn:concat(
  "http://", $const:RESTHOST, ':', $const:RESTPORT,
  "/v1/resources/caseactivity?rs:activityId=32345-activity1&amp;rs:patch=true")
let $response := xdmp:http-put($uri, $cmrt:user-one-options, $activity)
return (
  test:assert-equal('405',       xs:string($response[1]/http:code)),
  test:assert-equal(
    'Invalid content patch for activity 32345-activity1',
    xs:string($response[1]/http:message)),
  test:assert-equal(
    'invalid path: /c:case/c:phases/c:phase/c:activities/c:activity[@id="32345-activity1"]/c:something-to-remove/c:remove-this',
    xs:string($response[2]/error:error-response/error:message))
);
