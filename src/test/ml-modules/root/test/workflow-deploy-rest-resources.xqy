xquery version "1.0-ml";

module namespace r="http://marklogic.com/test/deploy-rest-resources";


declare function r:deploy() {
    let $rest-resources-query := 
       "xquery version '1.0-ml';
        map:new((
          for $resource in
            cts:search(fn:collection(), cts:or-query((
              cts:directory-query('/app/config/', 'infinity'),
              cts:directory-query('/Default/', 'infinity'),
              cts:directory-query('/marklogic.rest.resource/', 'infinity')
              )) 
            )
          return map:entry(fn:base-uri($resource), $resource)
        ))"
  let $perms-resources-query := 
       "xquery version '1.0-ml';
        map:new((
          for $resource in
            cts:search(fn:collection(), cts:or-query((
              cts:directory-query('/Default/', 'infinity'),
              cts:directory-query('/marklogic.rest.resource/', 'infinity')
              )) 
            )
          return map:entry(fn:base-uri($resource), xdmp:document-get-permissions(fn:base-uri($resource)))
        ))"       
    
    let $resources :=  
        xdmp:eval($rest-resources-query, (), 
                <options xmlns="xdmp:eval">
                    <database>{xdmp:database(fn:replace(xdmp:database-name(xdmp:modules-database()), '-test', ''))}</database>
                </options> )
    let $permissions :=  
        xdmp:eval($perms-resources-query, (), 
                <options xmlns="xdmp:eval">
                    <database>{xdmp:database(fn:replace(xdmp:database-name(xdmp:modules-database()), '-test', ''))}</database>
                </options> )
                
    let $import-query := 
        "xquery version '1.0-ml';
         declare variable $uri as xs:string external;
         declare variable $content as item() external;
         declare variable $perms as element() external;
         (:$perms/node():)
         xdmp:document-insert($uri, $content, $perms/node())
         
         "
                
    return 
  
    for $key in map:keys($resources) return
        xdmp:eval($import-query, 
                  (xs:QName("uri"), $key, xs:QName("content"), document{map:get($resources, $key)}, 
                  xs:QName("perms"), <root>{map:get($permissions, $key)}</root>
                  ),
                  <options xmlns="xdmp:eval">
                    <database>{xdmp:modules-database()}</database>
                    <isolation>different-transaction</isolation> 
                  </options> )
    

};

