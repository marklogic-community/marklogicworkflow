xquery version "1.0-ml";
module namespace wrt = "http://marklogic.com/workflow/rest-tests";

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace process = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";
declare namespace http = "xdmp:http";


declare function wrt:test-09-11-12-xml-payload ($pid)
{
  <ext:updateRequest xmlns:ext="http://marklogic.com/rest-api/resource/process" xmlns:wf="http://marklogic.com/workflow">
    <ext:processId>{$pid}</ext:processId>
    <wf:data>
    </wf:data>
    <wf:attachments>
    </wf:attachments>
  </ext:updateRequest>
};

declare function wrt:test-13-xml-payload ($pid)
{
  <ext:updateRequest xmlns:ext="http://marklogic.com/rest-api/resource/process" xmlns:wf="http://marklogic.com/workflow">
    <ext:processId>{$pid}</ext:processId>
    <wf:data>
      <unlock-new-data>Some data created on request to unlock</unlock-new-data>
    </wf:data>
    <wf:attachments></wf:attachments>
  </ext:updateRequest>
};

declare function wrt:test-14-15-17-xml-payload ($pid)
{
  <ext:updateRequest xmlns:ext="http://marklogic.com/rest-api/resource/process" xmlns:wf="http://marklogic.com/workflow">
    <ext:processId>{$pid}</ext:processId>
    <wf:data>
      <complete-data>Some data added by complete action</complete-data>
    </wf:data>
    <wf:attachments></wf:attachments>
  </ext:updateRequest>
};

declare function wrt:processmodel-create ($options, $filename)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processmodel?rs:name=", $filename,
    "&amp;rs:enable=true")
  let $fullpath := fn:concat("/raw/bpmn/", $filename)
  let $file := fn:doc($fullpath)
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:processmodel-create ($options as element(), $filename as xs:string, $major-version as xs:int,$minor-version as xs:int)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processmodel?rs:name=", $filename,
    "&amp;rs:major=",$major-version,"&amp;rs:minor=",$minor-version,
    "&amp;rs:enable=true")
  let $fullpath := fn:concat("/raw/bpmn/", $filename)
  let $file := fn:doc($fullpath)
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:processmodel-publish ($options, $modelid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processmodel?rs:publishedId=",
    $modelid)
  let $file := <somexml/>
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:process-create ($options, $payload)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process")
  let $file := $payload
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:process-read ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid))
  return xdmp:http-get($uri, $options)
};

declare function wrt:process-read-all ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:part=all")
  return xdmp:http-get($uri, $options)
};

(: REST test specific functions :)

declare function wrt:test-02-processmodel-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processmodel?rs:publishedId=015-restapi-tests__1__0")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-03-processmodel-update ($options)
{
  wrt:processmodel-create($options,"015-restapi-tests.bpmn",1,2)
  (:let $uri := fn:concat(015-restapi-tests.bpmn
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processmodel?rs:name=015-restapi-tests.bpmn&amp;rs:major=1&amp;rs:minor=2")
  let $file := fn:doc("/raw/bpmn/015-restapi-tests.bpmn")
  return xdmp:http-put($uri, $options, $file):)
};

declare function wrt:test-08-processinbox-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processinbox")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-09-process-update ($options, $pid)
{
  let $_ := xdmp:log(fn:concat("options=", xdmp:quote($options)))
  let $_ := xdmp:log(fn:concat("pid=", $pid))
  let $uri := fn:concat(
      "http://", $const:RESTHOST, ':', $const:RESTPORT,
      "/v1/resources/process?rs:processid=",
      fn:encode-for-uri($pid), "&amp;rs:complete=true")
  let $_ := xdmp:log(fn:concat("uri=", $uri))
  let $file := wrt:test-09-11-12-xml-payload($pid)
  let $_ := xdmp:log(fn:concat("file=", xdmp:quote($file)))
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-10-processqueue-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processqueue?rs:queue=Editors")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-11-process-update-lock ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:lock=true")
  let $file := wrt:test-09-11-12-xml-payload($pid)
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-12-process-update-lock-fail ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:lock=true")
  let $file := wrt:test-09-11-12-xml-payload($pid)
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-13-process-update-unlock ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:unlock=true")
  let $file := wrt:test-13-xml-payload($pid)
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-14-process-update-lock ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:lock=true")
  let $file := wrt:test-14-15-17-xml-payload($pid)
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-15-17-process-update ($options, $pid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/process?rs:processid=", fn:encode-for-uri($pid),
    "&amp;rs:complete=true")
  let $file := wrt:test-14-15-17-xml-payload($pid)
  return xdmp:http-post($uri, $options, $file)
};


(: functions specific to email tests... :)
declare function wrt:test-25-processsubscription-create ($options)
{
  let $payload := fn:doc("/raw/data/25-payload.xml")
  return 
  wrt:test-processsubscription-create($options,$payload)
};

declare function wrt:test-processsubscription-create ($options,$payload)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processsubscription")
  return xdmp:http-put($uri, $options, $payload)
};

declare function wrt:test-processsubscription-read ($options,$subscription-name as xs:string)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processsubscription?rs:name="||$subscription-name)
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-26-processsubscription-read ($options)
{
  let $subscription-name := "email-sub-test"
  return
  wrt:test-processsubscription-read($options,$subscription-name)
};

declare function wrt:test-processsubscription-delete ($options,$subscription-name as xs:string)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processsubscription?rs:name="||$subscription-name)
  return xdmp:http-delete($uri, $options)
};

declare function wrt:test-27-document-create ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/documents?uri=/some/doc.xml&amp;collection=/test/email/sub")
  let $file := fn:doc("/raw/data/27-payload.xml")
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:test-28-processsearch-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processsearch?rs:processname=022-email-test__1__0")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-29-processasset-create ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processasset?rs:model=021-initiating-attachment",
    "&amp;rs:major=1&amp;rs:minor=3&amp;rs:asset=RejectedEmail.txt")
  let $file := fn:doc("/raw/data/RejectedEmail.txt")
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:test-30-processasset-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processasset?rs:model=021-initiating-attachment",
    "&amp;rs:major=1&amp;rs:minor=3&amp;rs:asset=RejectedEmail.txt")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-31-processasset-delete ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processasset?rs:model=021-initiating-attachment",
    "&amp;rs:major=1&amp;rs:minor=3&amp;rs:asset=RejectedEmail.txt")
  return xdmp:http-delete($uri, $options)
};

(: big jump - only 91 was being run in shtests :)
declare function wrt:test-91-processengine-read ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processengine")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-92-processengine-delete ($options)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/processengine")
  return xdmp:http-delete($uri, $options)
};

declare function wrt:call-complete-on-pid($options as element(http:options),$pid as xs:string){
  let $payload := 
  element process:updateRequest{
    element process:processId{$pid},
    /wf:process[@id = $pid]/(wf:data|wf:attachments)
  }
  let $uri := fn:concat(
      "http://", $const:RESTHOST, ':', $const:RESTPORT,
      "/v1/resources/process?rs:processid=",
      fn:encode-for-uri($pid), "&amp;rs:complete=true")    
  return xdmp:http-post($uri, $options, $payload)[2]
};

declare function wrt:process-delete($options as element(http:options),$pid as xs:string){
  let $uri := fn:concat(
      "http://", $const:RESTHOST, ':', $const:RESTPORT,
      "/v1/resources/process?rs:processid=",
      fn:encode-for-uri($pid)
  )    
  return xdmp:http-delete($uri, $options)[2]
};
