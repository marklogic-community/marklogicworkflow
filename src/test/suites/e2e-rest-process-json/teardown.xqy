xquery version "1.0-ml";
import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

let $tidyup := uh:remove-user("test-workflow-user")
let $clean-data := (xdmp:directory-delete("/"), xdmp:collection-delete("http://marklogic.com/cpf/pipelines"))
return ()
