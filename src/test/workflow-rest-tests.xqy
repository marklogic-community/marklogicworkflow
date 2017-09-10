xquery version "1.0-ml";
module namespace wrt = "http://marklogic.com/workflow/rest-tests";

import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";

declare function wrt:test-01-processmodel-create ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processmodel?rs:name=015-restapi-tests.bpmn&amp;enable=true")
  let $file := doc("/raw/data/015-restapi-tests.bpmn")
  (:  let $process := xdmp:http-put($uri, $options, $file)
:)
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:test-02-processmodel-read ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processmodel?rs:publishedId=015-restapi-tests.bpmn")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-03-processmodel-update ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processmodel?rs:name=015-restapi-tests.bpmn&amp;rs:major=1&amp;rs:minor=2")
  let $file := doc("/raw/data/015-restapi-tests.bpmn")
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:test-04-processmodel-publish ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processmodel?rs:publishedId=015-restapi-tests__1__2")
  let $file := <somexml/>
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-06-process-create ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/process")
  let $file := doc("/raw/data/06-payload.xml")
  return xdmp:http-put($uri, $options, $file)
};

declare function wrt:test-07-process-read ($options, $pid)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/process?rs:processid=", $pid)
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-08-processinbox-read ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processinbox")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-09-process-update ($options, $pid)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/process?rs:processid=", $pid, "&amp;rs:complete=true")
  let $file := doc("/raw/data/09-payload.xml")
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-10-processqueue-read ($options)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/processqueue?rs:queue=Editors")
  return xdmp:http-get($uri, $options)
};

declare function wrt:test-11-process-update-lock ($options, $pid)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/process?rs:processid=", $pid, "&amp;rs:lock=true")
  let $file := doc("/raw/data/11-payload.xml")
  return xdmp:http-post($uri, $options, $file)
};

declare function wrt:test-12-process-update-lock-fail ($options, $pid)
{
  let $uri := fn:concat("http://", $c:RESTHOST, ':', $c:RESTPORT, "/v1/resources/process?rs:processid=", $pid, "&amp;rs:lock=true")
  let $file := doc("/raw/data/12-payload.xml")
  return xdmp:http-post($uri, $options, $file)
};

