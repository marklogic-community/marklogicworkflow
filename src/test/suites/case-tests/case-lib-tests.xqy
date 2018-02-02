xquery version "1.0-ml";

(: 01 - new case ids :)
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";
for $source in (
  <c:case id="12345"/>,
  <c:phase id="12345"/>,
  <c:activity id="12345"/>
)
let $caseid := clib:get-new-id($source)
return (
  test:assert-equal("12345", $caseid)
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $caseid := clib:get-new-id(())
return (
  test:assert-meets-minimum-threshold(58, fn:string-length($caseid))
);


