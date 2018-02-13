xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

return (
  test:load-test-file("case-post-payload.xml", xdmp:database(), "/raw/data/case-post-payload.xml"),
  test:load-test-file("case-put-payload.xml", xdmp:database(), "/raw/data/case-put-payload.xml"),
  test:load-test-file("activity-payload.xml", xdmp:database(), "/raw/data/activity-payload.xml"),
  test:load-test-file("22345.xml", xdmp:database(), "/raw/data/22345.xml"),
  test:load-test-file("22345.xml", xdmp:database(), "/casemanagement/cases/notemplate/22345.xml")
);

(
  xdmp:document-set-collections(
    "/casemanagement/cases/notemplate/22345.xml",
    "http://marklogic.com/casemanagement/cases"
  ),
  xdmp:document-set-permissions(
    "/casemanagement/cases/notemplate/22345.xml",
    (
      xdmp:permission("test-case-role-one", "read"),
      xdmp:permission("test-case-role-one", "insert"),
      xdmp:permission("test-case-role-one", "update")
    )
  )
);
