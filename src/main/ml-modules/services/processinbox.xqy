xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processinbox";

(: import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy"; :)
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

import module namespace http-codes = "http://marklogic.com/workflow/http-codes" at "/lib/http-codes.xqy";
import module namespace http-util = "http://marklogic.com/workflow/http-util" at "/lib/http-util.xqy";
import module namespace string-util = "http://marklogic.com/workflow/string-util" at "/lib/string-util.xqy";

declare namespace rapi= "http://marklogic.com/rest-api";
declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf="http://marklogic.com/workflow";


(:
 : Fetch a process inbox for the current user
 : Returns the full process document
 :)
declare
%roxy:params("user=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := http-util:get-accept-type($context)
  let $_ := xdmp:trace("ml-workflow","processmodel-get : requested type = "||$preftype)
  
  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $inbox := wfu:inbox( map:get($params,"user"))

  let $out :=
      <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
        {$inbox}
      </ext:readResponse>

  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),
    document {
      if(http-util:xml-response-requested($context)) then
        $out
      else if(http-util:html-response-requested($context)) then
        typeswitch($inbox)
          case(document-node()) return xml-to-html($inbox/element())
          default return xml-to-html($inbox)
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )
};

declare function xml-to-html($object as element()){  
  typeswitch($object)
    case(element(wf:inbox))
    return
    element html{
      element body{
        for $element in $object/wf:task
        let $process := $element/wf:process-data/wf:process
        let $process-name as xs:string? := $process/@title
        let $process-link as xs:string? := "/v1/resources/process?rs:processid="||$process/@id
        return
        element div {
          element h3{string-util:dash-format-string(fn:local-name($element))}
          ,
          element div{
            element p { "Process: ", element a { attribute href{$process-link}, $process-name}}
          },
          element div{
            element p { "Properties: "},
            element dl {
              for $prop in $element/wf:process-properties/*/wf:*
              return
              (element dt {string-util:dash-format-string(fn:local-name($prop))}, element dd {$prop/text()})
            }
          }
        }        
      }
    }
    default return $object
};

