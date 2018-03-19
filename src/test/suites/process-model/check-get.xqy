(:
  In this test we 'GET' with a process model name
  The result should be a list of the different versions of that model
  In the setup for the test we create two different verions of $test-constants:TEST-MODEL-NAME - this is reflected in the output
:)
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/process-model" at "/test/suites/process-model/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare option xdmp:mapping "false";

for $test-model-name in $test-constants:TEST-MODEL-NAMES
let $model-input-file-name := wth:file-name-for-model($test-model-name)
return
wrt:processmodel-create ($const:xml-options, $model-input-file-name)[0]
,
let $model-input-file-name := wth:file-name-for-model($test-constants:TEST-MODEL-NAME)
return
wrt:processmodel-create ($const:xml-options,$model-input-file-name,1,2)[0]
;
import module namespace mime-types = "http://marklogic.com/workflow/mime-types" at "/lib/mime-types.xqy";
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/process-model" at "/test/suites/process-model/lib/constants.xqy";

declare default function namespace "x";

declare namespace http = "xdmp:http";

declare variable $endpoint as xs:string := fn:concat("/LATEST/resources/processmodel?rs:name=",$test-constants:TEST-MODEL-NAME);

let $xml-output := xdmp:http-get(wth:rest-uri($test-config:RESTHOST,xs:int($test-config:RESTPORT),$endpoint),wth:http-options($mime-types:XML,$test-config:USER,$test-config:PASSWORD))
let $data-response := $xml-output[2]/element()
let $expected-response := 
<wf:process-models xmlns:wf="http://marklogic.com/workflow">
<wf:process-model>
    <wf:process-model-full-name>test-model-1__1__2</wf:process-model-full-name>
    <wf:link>/LATEST/resources/processmodel?name=test-model-1__1__2</wf:link>
</wf:process-model>
<wf:process-model>
    <wf:process-model-full-name>test-model-1__1__0</wf:process-model-full-name>
    <wf:link>/LATEST/resources/processmodel?name=test-model-1__1__0</wf:link>
</wf:process-model>
</wf:process-models>
return
(
  test:assert-true(fn:deep-equal($expected-response,$data-response)),
  test:assert-true(fn:matches($xml-output/http:headers/http:content-type/text(),$mime-types:XML))
)  
,
let $html-output := xdmp:http-get(wth:rest-uri($test-config:RESTHOST,xs:int($test-config:RESTPORT),$endpoint),wth:http-options($mime-types:HTML,$test-config:USER,$test-config:PASSWORD))
let $data-response := $html-output[2]/text()
let $expected-response := 
<html>
    <body>
        <h3>Process Models</h3>
        <div>
            <div>
                <a href="/LATEST/resources/processmodel?name=test-model-1__1__0">test-model-1__1__0</a>
            </div>
        </div>
        <div>
            <div>
                <a href="/LATEST/resources/processmodel?name=test-model-1__1__2">test-model-1__1__2</a>
            </div>
        </div>
    </body>
</html>
return
(
  test:assert-true(fn:deep-equal(xdmp:unquote($data-response)/element(),$expected-response)),
  test:assert-true(fn:matches($html-output/http:headers/http:content-type/text(),$mime-types:HTML))  
)  
,
let $json-output := xdmp:http-get(wth:rest-uri($test-config:RESTHOST,xs:int($test-config:RESTPORT),$endpoint),wth:http-options($mime-types:JSON,$test-config:USER,$test-config:PASSWORD))
let $data-response := $json-output[2]/object-node()
let $expected-response := 
object-node{
  "processModels": object-node{
    "processModel": array-node{
      object-node{
        "processModelFullName": "test-model-1__1__2",
        "link": "/LATEST/resources/processmodel?name=test-model-1__1__2"
      },
      object-node{
        "processModelFullName": "test-model-1__1__0",
        "link": "/LATEST/resources/processmodel?name=test-model-1__1__0"
      }
    }
  }
}
return
(
  test:assert-true(fn:deep-equal($data-response,$expected-response)),
  test:assert-true(fn:matches($json-output/http:headers/http:content-type/text(),$mime-types:JSON))  
)  
  
