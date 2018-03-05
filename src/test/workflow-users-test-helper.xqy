xquery version "1.0-ml";

module namespace uh = "http://marklogic.com/roxy/test-models/workflow-users-test-helper";

declare function uh:create-user($username as xs:string, $description as xs:string, $password as xs:string, $role-names as xs:string*){
    xdmp:eval(
       " xquery version '1.0-ml';
         import module namespace sec = 'http://marklogic.com/xdmp/security' at '/MarkLogic/security.xqy';
         declare variable $username as xs:string external;
         declare variable $description as xs:string external;
         declare variable $password as xs:string external;
         declare variable $role-names-concatenated as xs:string external;

         try {
            sec:create-user($username, $description, $password, (fn:tokenize($role-names-concatenated, '~')), (), (), ())
         } catch  ($e) {
           if($e/*:code = 'SEC-USEREXISTS') then 'already exists' else fn:error($e)
         }
       ",
       (xs:QName("username"), $username,
        xs:QName("description"), $description,
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

         if(sec:user-exists($username)) then
          sec:remove-user($username)
         else          
          ()
       ",
       (xs:QName("username"), $username),
        <options xmlns="xdmp:eval">
            <database>{xdmp:database("Security")}</database>
        </options>
    )
};
