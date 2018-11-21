xquery version "1.0-ml";
(:
  $caseid as xs:string?,         (: should always be supplied - new case will supply new caseid :)
  $new-case as xs:boolean,       (: is this new? :)
  $input-data as xs:boolean,     (: is there data? :)
  $input-expected as xs:boolean  (: should there be data? :)
:)
(: 01 - new case :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("newid", fn:true(), fn:true(), fn:true())
return (
  test:assert-equal(200,                            map:get($validate, "status-code")),
  test:assert-equal("OK",                           map:get($validate, "response-message"))
);

(: 02 - get existing case :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("12345", fn:false(), fn:false(), fn:false())
return (
  test:assert-equal(200,                            map:get($validate, "status-code")),
  test:assert-equal("OK",                           map:get($validate, "response-message"))
);

(: 03 - update existing case :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("12345", fn:false(), fn:true(), fn:true())
return (
  test:assert-equal(200,                            map:get($validate, "status-code")),
  test:assert-equal("OK",                           map:get($validate, "response-message"))
);

(: 04 - all - no case id; should always throw error :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseid := ()
for $new-case in (fn:false(), fn:true())
  for $input-data in (fn:false(), fn:true())
    for $input-expected in (fn:false(), fn:true())
      let $validate := ch:validate($caseid, $new-case, $input-data, $input-expected)
      return (
        test:assert-equal(404,                            map:get($validate, "status-code")),
        test:assert-equal("Case not found",               map:get($validate, "response-message")),
        test:assert-equal("caseId parameter is required", map:get($validate, "error-detail"))
      );

(: 05 - new case - existing id :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
for $input-data in (fn:false(), fn:true())
  for $input-expected in (fn:false(), fn:true())
    let $validate := ch:validate("12345", fn:true(), $input-data, $input-expected)
    return (
      test:assert-equal(400,                            map:get($validate, "status-code")),
      test:assert-equal("Invalid ID supplied",          map:get($validate, "response-message")),
      test:assert-equal("caseId 12345 exists",          map:get($validate, "error-detail"))
    );

(: 06 - update/get case where id does not exist :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
for $input-data in (fn:false(), fn:true())
  for $input-expected in (fn:false(), fn:true())
    let $validate := ch:validate("newid", fn:false(), $input-data, $input-expected)
    return (
      test:assert-equal(400,                            map:get($validate, "status-code")),
      test:assert-equal("Invalid ID supplied",          map:get($validate, "response-message")),
      test:assert-equal("caseId newid not found",       map:get($validate, "error-detail"))
    );

(: 07 - create new case -no data :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("newid", fn:true(), fn:false(), fn:true())
return (
  test:assert-equal(405,                            map:get($validate, "status-code")),
  test:assert-equal("Invalid input",                map:get($validate, "response-message")),
  test:assert-equal("Nothing to insert",            map:get($validate, "error-detail"))
);

(: 08 - update existing case -no data :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("12345", fn:false(), fn:false(), fn:true())
return (
  test:assert-equal(405,                            map:get($validate, "status-code")),
  test:assert-equal("Invalid input",                map:get($validate, "response-message")),
  test:assert-equal("Nothing to update",            map:get($validate, "error-detail"))
);

(: 09 - contraversial ? receive data when not expected - ignore and carry on :)
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $validate := ch:validate("12345", fn:false(), fn:true(), fn:false())
return (
  test:assert-equal(200,                            map:get($validate, "status-code")),
  test:assert-equal("OK",                           map:get($validate, "response-message"))
);
