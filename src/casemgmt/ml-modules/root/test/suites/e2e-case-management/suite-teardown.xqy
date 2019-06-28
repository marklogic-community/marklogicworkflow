xquery version "1.0-ml";
import module namespace uh = "http://marklogic.com/test-models/workflow-users-test-helper" at "/test/workflow-users-test-helper.xqy";

(
  uh:remove-user("test-case-user-one"),
  uh:remove-user("test-case-user-two"),
  uh:remove-user("test-case-administrator"),
  uh:remove-role("test-case-role-one"),
  uh:remove-role("test-case-role-two")
)
