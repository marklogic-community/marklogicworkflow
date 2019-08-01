xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processqueue";

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
%roxy:params("queue=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := http-util:get-accept-type($context)
  let $_ := xdmp:trace("ml-workflow","process-get : requested type = "||$preftype)
  
  let $_ := map:put($context, "output-types", $preftype)

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $queue := wfu:queue( map:get($params,"queue") )

  let $out :=
    if (fn:empty(map:get($params,"queue"))) then
      <ext:readResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Parameter 'queue' is required.</ext:message></ext:readResponse>
    else
      <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
        {$queue}
      </ext:readResponse>

  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    document {
      if ( http-util:xml-response-requested($context)) then
      (
        map:put($context, "output-types", "application/xml"),
        $out
      )
      else if( http-util:html-response-requested($context)) then
        ext:xml-to-html( $queue)
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )  
};

declare function xml-to-html($object as element()*)
{  
  element html {
    element body {
      element h2 {"Queue"},
      element ul {
      for $task in $object/wf:task
      return
      element li { 
        element h3 {"Task"},
        element div {
          element p { 
            element b {"Process: "}, 
            let $process := $task/wf:process-data/wf:process
            return
              element a { attribute href { "/LATEST/resources/process?rs:processid="||$process/@id}, string( $process/@title)}
          }
        },
        element div {
          element-to-html($task/wf:process-properties/prop:properties)
        }
      }
      }
    }
  }  
};

declare function element-to-html( $node as node())
{
  typeswitch($node)
    case(element()) return
      element div { 
        element b {fn:name($node)||": "}, 
        element ul {
          $node/(node()|attribute()) ! element li { element-to-html(.) }
        }
      }
    case(attribute()) return
      element div { 
        element b {string-util:dash-format-string(fn:name($node))||": "}, fn:data( $node) 
      }
    default return
      fn:data( $node)
};

