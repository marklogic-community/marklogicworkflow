xquery version "1.0-ml";

(: 01 - new case ids :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

(:
 : TODO: Need tests for:
 :  - ch:validate
 :  - ch:validate-data
 :  - ch:validate-activity
 :  - ch:validation
 :  - ch:case-create
 :  - ch:case-update
 :  - ch:case-get
 :  - ch:case-close
 :  - ch:caseactivity-create
 :  - ch:caseactivity-update
:)

(:
let $params := map:new((
  map:entry("phaseId", "1"),
  map:entry("activityId", "12345"),
  map:entry("caseId", "12345")
)) :)
let $action-name := "get activity"
let $params := map:new((
  map:entry("activityId", "activity1")
))
let $input-data := ()

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(200, map:get($validate, "status-code")),
  test:assert-equal("OK", map:get($validate, "response-message")),
  test:assert-equal("activity1", map:get($validate, "activityId"))
);
(:
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseid := clib:get-new-id(())
return (
  test:assert-meets-minimum-threshold(58, fn:string-length($caseid))
);
:)

