xquery version "1.0-ml";

(: new attribute :)
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";
let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=  <c:case id="12345" template-id="ctemplate1" foo="thisisnew"></c:case>
let $new := clib:update-document($a, $b)
return (
  test:assert-equal(3, fn:count(($new/@*)))
);

(: can't update the id! :)
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";
let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=  <c:case id="888" template-id="ctemplate1"></c:case>
let $new := clib:update-document($a, $b)
return (
  test:assert-equal("12345", xs:string($new/@id))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <c:case id="12345" template-id="ctemplate1">
    <c:data>
      <c:latest-version>1</c:latest-version>
      <c:publication-date>12-01-2017</c:publication-date>
    </c:data>
  </c:case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal("1", xs:string($new/c:data/c:latest-version)),
  test:assert-equal("12-01-2017", xs:string($new/c:data/c:publication-date))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <c:case id="12345" template-id="ctemplate1">
    <c:active-phase>phase1</c:active-phase>
  </c:case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal("phase1", xs:string($new/c:active-phase))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <case id="12345" template-id="ctemplate1" xmlns="http://marklogic.com/workflow/case">
    <phases>
      <phase id="phase1" template-id="ptemplate1">
        <data>
          <name>Intial</name>
          <public-name>Updated Case Example</public-name>
        </data>
        <activities>
          <activity id="activity1" template-id="atemplate1">
            <data>
              <name>Contact Customer</name>
              <public-name>Contact Customer</public-name>
              <planned-start-date>11-05-2017</planned-start-date>
              <planned-end-date>10-06-2017</planned-end-date>
              <actual-start-date>15-05-2017</actual-start-date>
              <actual-end-date>14-06-2017</actual-end-date>
            </data>
          </activity>
        </activities>
      </phase>
    </phases>
  </case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal("Updated Case Example", xs:string($new/c:phases/c:phase/c:data/c:public-name)),
  test:assert-equal("Contact Customer", xs:string($new/c:phases/c:phase/c:activities/c:activity/c:data/c:name))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <case id="12345" template-id="ctemplate1" xmlns="http://marklogic.com/workflow/case">
    <attachments>
      <attachment>string</attachment>
      <attachment>newdocument</attachment>
    </attachments>
  </case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal(2, fn:count($new/c:attachments/c:attachment))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <case id="12345" template-id="ctemplate1" xmlns="http://marklogic.com/workflow/case">
    <status>Active</status>
  </case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal("Active", xs:string($new/c:status))
);

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";

let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <case id="12345" template-id="ctemplate1" xmlns="http://marklogic.com/workflow/case">
    <parent>100001</parent>
  </case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal("100001", xs:string($new/c:parent))
);


(: Put it all together! :)
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace c="http://marklogic.com/workflow/case";
let $a := doc("/casemanagement/cases/notemplate/12345.xml")/c:case
let $b :=
  <case id="888" template-id="ctemplate1" foo="thisisnew" xmlns="http://marklogic.com/workflow/case">
    <data>
      <latest-version>1</latest-version>
      <publication-date>12-01-2017</publication-date>
    </data>
    <active-phase>phase1</active-phase>
    <phases>
      <phase id="phase1" template-id="ptemplate1">
        <data>
          <name>Intial</name>
          <public-name>Updated Case Example</public-name>
        </data>
        <activities>
          <activity id="activity1" template-id="atemplate1">
            <data>
              <name>Contact Customer</name>
              <public-name>Contact Customer</public-name>
              <planned-start-date>11-05-2017</planned-start-date>
              <planned-end-date>10-06-2017</planned-end-date>
              <actual-start-date>15-05-2017</actual-start-date>
              <actual-end-date>14-06-2017</actual-end-date>
            </data>
          </activity>
        </activities>
      </phase>
    </phases>
    <attachments>
      <attachment>string</attachment>
      <attachment>newdocument</attachment>
    </attachments>
    <status>Active</status>
    <parent>100001</parent>
  </case>

let $new := clib:update-document($a, $b)
return (
  test:assert-equal(3, fn:count(($new/@*))),
  test:assert-equal("12345", xs:string($new/@id)),
  test:assert-equal("1", xs:string($new/c:data/c:latest-version)),
  test:assert-equal("12-01-2017", xs:string($new/c:data/c:publication-date)),
  test:assert-equal("phase1", xs:string($new/c:active-phase)),
  test:assert-equal("Updated Case Example", xs:string($new/c:phases/c:phase/c:data/c:public-name)),
  test:assert-equal("Contact Customer", xs:string($new/c:phases/c:phase/c:activities/c:activity/c:data/c:name)),
  test:assert-equal(2, fn:count($new/c:attachments/c:attachment)),
  test:assert-equal("Active", xs:string($new/c:status)),
  test:assert-equal("100001", xs:string($new/c:parent))
);




