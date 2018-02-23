xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace deploy  = "http://marklogic.com/roxy/deploy-rest-resources" at "/test/workflow-deploy-rest-resources.xqy";

let $_modules-import := deploy:deploy()

let $_load := (
  test:load-test-file("12345.xml", xdmp:database(), "/casemanagement/cases/notemplate/12345.xml"),
  test:load-test-file("1.xml", xdmp:database(), "/casemanagement/cases/notemplate/1.xml")
)

return (
  xdmp:document-set-collections("/casemanagement/cases/notemplate/12345.xml", "http://marklogic.com/casemanagement/cases"),
  xdmp:document-set-collections("/casemanagement/cases/notemplate/1.xml",     "http://marklogic.com/casemanagement/cases")
)
