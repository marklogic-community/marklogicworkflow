xquery version "1.0-ml";

import module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

let $create-roles := (
  uh:create-role("test-case-role-one", ("workflow-role-unit-test", "case-user"), () ),
  uh:create-role("test-case-role-two", ("workflow-role-unit-test", "case-user"), () )
)
return (
  uh:create-user("test-case-user-one", "test-case-user-one",
    ("workflow-role-unit-test", "test-case-role-one") ),
  uh:create-user("test-case-user-two", "test-case-user-two",
    ("workflow-role-unit-test", "test-case-role-two") ),
  uh:create-user("test-case-administrator", "test-case-administrator",
    ("workflow-role-unit-test", "case-administrator") )
)
