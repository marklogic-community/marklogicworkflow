xquery version "1.0-ml";

(:
 : TODO: Need tests for:
 :  - patch:apply-patch
 :)

(: patch:convert-path tests - good :)
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

(
  test:assert-equal(
    "/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]",
    patch:convert-path("activity1", "/c:activity", json:array())),
  test:assert-equal(
    "/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]/c:data/c:public-name",
    patch:convert-path("activity1", "/c:activity/c:data/c:public-name", json:array())),
  test:assert-equal(
    "/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]//c:child/c:grandchild",
    patch:convert-path("activity1", "/c:activity//c:child/c:grandchild", json:array()))
);

(: patch:convert-path tests - bad :)
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

let $error-list := json:array()
let $res := patch:convert-path("activity1", "/activity", $error-list)
return
  test:assert-equal("unable to interpret path: /activity", string-join(json:array-values($error-list,true()), ", "))
;

(: patch:convert-path tests - ugly :)
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

let $error-list := json:array()
let $res := patch:convert-path("activity1", "/c:activity]", $error-list)
return
  test:assert-equal("invalid path: /c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]]", string-join(json:array-values($error-list,true()), ", "))
;

(: patch:convert-xml-operation tests :)
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

let $error-list := json:array()
let $node := <rapi:delete select="//c:child/c:grandchild"/>
let $converted := patch:convert-xml-operation("activity1", $node, $node/@select, $error-list)
return (
  test:assert-equal("/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]//c:child/c:grandchild", xs:string($converted/@select))
);

import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

let $error-list := json:array()
let $node :=
  <rapi:insert context="/c:activity" position="last-child">
    <c:inserted/>
  </rapi:insert>
let $converted := patch:convert-xml-operation("activity1", $node, $node/@context, $error-list)
return (
  test:assert-equal("/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]", xs:string($converted/@context)),
  test:assert-exists($converted/c:inserted)
);

(: TODO - need to test some failures :)

(: patch:convert-xml-patch tests :)
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";
declare namespace c="http://marklogic.com/workflow/case";

let $patches :=
  <rapi:patch id="activity1" xmlns:c="http://marklogic.com/workflow/case">
    <rapi:insert context="/c:activity" position="last-child">
      <c:inserted/>
    </rapi:insert>
    <rapi:replace select="/c:activity/c:data/c:public-name">
      <c:public-name>Lets Contact Customer</c:public-name>
    </rapi:replace>
    <rapi:delete select="//c:child/c:grandchild"/>
  </rapi:patch>
let $activity-id := "activity1"

let $error-list := json:array()
let $converted := patch:convert-xml-patch($activity-id, $patches, $error-list)
return (
  test:assert-equal(2, fn:count($converted/rapi:insert[@position = "last-child"])),
  (: check paths converted and nothing lost :)
  test:assert-equal("/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]", xs:string($converted/rapi:insert[1]/@context)),
  test:assert-exists($converted/rapi:insert/c:inserted),
  test:assert-equal("/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]/c:data/c:public-name", xs:string($converted/rapi:replace/@select)),
  test:assert-exists($converted/rapi:replace/c:public-name),
  test:assert-equal("/c:case/c:phases/c:phase/c:activities/c:activity[@id=&quot;activity1&quot;]//c:child/c:grandchild", xs:string($converted/rapi:delete/@select)),
  (: do we have an audit trail ? :)
  test:assert-equal("/c:case/c:audit-trail", xs:string($converted/rapi:insert[2]/@context)),
  test:assert-equal("admin", xs:string($converted/rapi:insert[@context="/c:case/c:audit-trail"]/c:audit/c:by)),
  test:assert-exists($converted/rapi:insert[@context="/c:case/c:audit-trail"]/c:audit/c:when),
  test:assert-equal("Lifecycle", xs:string($converted/rapi:insert[@context="/c:case/c:audit-trail"]/c:audit/c:category)),
  test:assert-equal("Open", xs:string($converted/rapi:insert[@context="/c:case/c:audit-trail"]/c:audit/c:status)),
  test:assert-equal("Case Activity activity1 Patched", xs:string($converted/rapi:insert[@context="/c:case/c:audit-trail"]/c:audit/c:description))
);

