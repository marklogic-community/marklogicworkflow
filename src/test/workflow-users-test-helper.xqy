xquery version "1.0-ml";

module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper";

declare function uh:create-user($username as xs:string, $password as xs:string, $role-names as xs:string*){
    xdmp:eval(
       " xquery version '1.0-ml';
         import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';
         declare variable $username as xs:string external;
         declare variable $password as xs:string external;
         declare variable $role-names-concatenated as xs:string external;

         try {
           sec:create-user($username, 'DELETE THIS USER IF TESTS ARE NOT BEING RUN!', $password, (fn:tokenize($role-names-concatenated, '~')), (), (), ())
         } catch  ($e) {
           if($e/*:code = 'SEC-USEREXISTS') then 'already exists' else fn:error($e)
         }
       ",
       (xs:QName("username"), $username,
        xs:QName("password"), $password,
        xs:QName("role-names-concatenated"), fn:string-join($role-names, "~")
       ),
        <options xmlns="xdmp:eval">
            <database>{xdmp:database("Security")}</database>
        </options>
    )
};

declare function uh:remove-user($username as xs:string){
    xdmp:eval(
       " xquery version '1.0-ml';
         import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';
         declare variable $username as xs:string external;

         sec:remove-user($username)
       ",
       (xs:QName("username"), $username),
        <options xmlns="xdmp:eval">
            <database>{xdmp:database("Security")}</database>
        </options>
    )
};

declare function uh:create-role(
  $rolename as xs:string,
  $role-names as xs:string*,
  $collections as xs:string*)
{
  xdmp:eval("
         xquery version '1.0-ml';
         import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';
         declare variable $rolename as xs:string external;
         declare variable $role-names-concatenated as xs:string external;
         declare variable $collections-concatenated as xs:string external;

         try {
           sec:create-role($rolename, 'DELETE THIS ROLE IF TESTS ARE NOT BEING RUN!', (fn:tokenize($role-names-concatenated, '~')), (), (fn:tokenize($collections-concatenated, '~')))
         } catch  ($e) {
           if($e/*:code = 'SEC-USEREXISTS') then 'already exists' else fn:error($e)
         }
       ",
    (
      xs:QName("rolename"), $rolename,
      xs:QName("role-names-concatenated"), fn:string-join($role-names, "~"),
      xs:QName("collections-concatenated"), fn:string-join($collections, "~")
    ),
    <options xmlns="xdmp:eval">
      <database>{xdmp:database("Security")}</database>
    </options>
  )
};

declare function uh:remove-role($rolename as xs:string){
  xdmp:eval(
    " xquery version '1.0-ml';
         import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';
         declare variable $rolename as xs:string external;

         sec:remove-role($rolename)
       ",
    (xs:QName("rolename"), $rolename),
    <options xmlns="xdmp:eval">
      <database>{xdmp:database("Security")}</database>
    </options>
  )
};
