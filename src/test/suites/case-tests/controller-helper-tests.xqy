xquery version "1.0-ml";

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

(: validation: new case - fail :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12345")
))
let $input-data := ()

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(400, map:get($validate, "status-code")),
  test:assert-equal("caseId 12345 exists", map:get($validate, "error-detail")),
  test:assert-equal("Invalid ID supplied", map:get($validate, "response-message"))
);

(: validation: new case - fail :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12346")
))
let $input-data := ()

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(405, map:get($validate, "status-code")),
  test:assert-equal("Nothing to insert", map:get($validate, "error-detail")),
  test:assert-equal("Invalid input", map:get($validate, "response-message"))
);

(: validation: new case - pass :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12346")
))
let $input-data := <c:case id="12346"></c:case>

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(200, map:get($validate, "status-code")),
  test:assert-equal("12346", map:get($validate, "caseId")),
  test:assert-equal("OK", map:get($validate, "response-message"))
);

(: validation: new case - pass :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12346"),
  map:entry("permission", ("case-user:read", "case-user:update"))
))
let $input-data := <c:case id="12346"></c:case>

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(200, map:get($validate, "status-code")),
  test:assert-equal("12346", map:get($validate, "caseId")),
  test:assert-equal("OK", map:get($validate, "response-message"))
);

(: validation: new case - fail :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12346"),
  map:entry("permission", ("case-user:read", "case-user:add-cheesy-topping"))
))
let $input-data := <c:case id="12346"></c:case>

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(405, map:get($validate, "status-code")),
  test:assert-equal("Illegal Capability", map:get($validate, "error-detail")),
  test:assert-equal("Invalid input", map:get($validate, "response-message"))
);

(: validation: new case - fail :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $action-name := "new case"
let $params := map:new((
  map:entry("caseId", "12346"),
  map:entry("permission", ("case-user:read", "this-role-doesnt-exist:update"))
))
let $input-data := <c:case id="12346"></c:case>

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(405, map:get($validate, "status-code")),
  test:assert-equal("Role does not exist", map:get($validate, "error-detail")),
  test:assert-equal("Invalid input", map:get($validate, "response-message"))
);


(: validation: retrieve activity - pass :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

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

(: validation: retrieve activity - fail :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

let $action-name := "get activity"
let $params := map:new((
  map:entry("caseId", "12345")
))
let $input-data := ()

let $validate := ch:validation($action-name, $params, $input-data)
return (
  test:assert-equal(404, map:get($validate, "status-code")),
  test:assert-equal("activityId parameter is required", map:get($validate, "error-detail")),
  test:assert-equal("Activity not found", map:get($validate, "response-message"))
);

(:
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseid := clib:get-new-id(())
return (
  test:assert-meets-minimum-threshold(58, fn:string-length($caseid))
);
:)

