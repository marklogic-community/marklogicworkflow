xquery version "1.0-ml";
module namespace uh = "http://marklogic.com/test-models/workflow-users-test-helper";

import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';

declare function uh:create-user($username as xs:string, $password as xs:string, $role-names as xs:string*){
  xdmp:invoke-function(
    function() {
      try {
        sec:create-user($username, 'DELETE THIS USER IF TESTS ARE NOT BEING RUN!', $password, $role-names, (), (), ())
      } catch  ($e) {
        if($e/*:code = 'SEC-USEREXISTS') then 'already exists' else fn:error($e)
      }
    },
    map:entry('database', xdmp:database("Security"))
  )
};

declare function uh:remove-user($username as xs:string){
  xdmp:invoke-function(
    function() {
      if (sec:user-exists($username))
      then sec:remove-user($username)
      else ()
    },
    map:entry('database', xdmp:database("Security"))
  )
};

declare function uh:create-role(
  $rolename as xs:string,
  $role-names as xs:string*,
  $collections as xs:string*)
{
  xdmp:invoke-function(
    function() {
      try {
        sec:create-role($rolename, 'DELETE THIS ROLE IF TESTS ARE NOT BEING RUN!', $role-names, (), $collections)
      } catch  ($e) {
        if($e/*:code = 'SEC-ROLEEXISTS') then 'already exists' else fn:error($e)
      }
    },
    map:entry('database', xdmp:database("Security"))
  )
};

declare function uh:remove-role($rolename as xs:string){
  xdmp:invoke-function(
    function() {
      if (sec:role-exists($rolename))
      then sec:remove-role($rolename)
      else ()
    },
    map:entry('database', xdmp:database("Security"))
  )
};
