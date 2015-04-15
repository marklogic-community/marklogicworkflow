xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processmodel";

import module namespace wfi="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";

declare namespace roxy = "http://marklogic.com/roxy";


(:
 : Get the process asset by exact name and version. Will return top level default is no versioned asset exists.
 :  ?asset=name&model=name[&major=numeric[&minor=numeric]]
 :  E.g. ?asset=RejectedEmail.txt&model=021-initiating-attachment&majorversion=1&minorversion=0
 :  TODO if no asset name specific, list assets for process model
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  (
    xdmp:set-response-code(200, "OK"),

    document {


    }
  )
};


(:
 : Update the process asset
 :  ?asset=name&model=name[&major=numeric[&minor=numeric]]
 :)
declare
%roxy:params("")
function ext:put(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()?
{
  (
    xdmp:set-response-code(200, "OK"),
    document {
    }
  )
};

(: TODO delete asset :)
