xquery version "1.0-ml";
module namespace cmrt = "http://marklogic.com/roxy/casemanagement/rest-tests";

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/case";
declare namespace http = "xdmp:http";

(: ID specific functions :)

declare function cmrt:get-case-id ($cdocuri)
{
  doc($cdocuri)/test/caseId/text()
};

declare function cmrt:get-transaction-id ($tdocuri)
{
  doc($tdocuri)/test/transactionId/text()
};

(: DB document test functions :)

declare function cmrt:fail-db-case-doc ($caseId)
{
  let $uri := fn:concat("/casemanagement/cases/notemplate/" || $caseId || ".xml")
  return (
    test:assert-not-exists(doc($uri))
  )
};

declare function cmrt:pass-db-case-doc ($caseId)
{
  let $uri := fn:concat("/casemanagement/cases/notemplate/" || $caseId || ".xml")
  return (
    test:assert-exists(doc($uri))
  )
};

(: TRANSACTION specific functions :)

declare function cmrt:create-transaction ($tdocuri)
{
  let $txuri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/transactions")
  let $response := xdmp:http-post($txuri, $const:xml-options)
  let $tx := xs:string($response/http:headers/http:location)
  let $txid := fn:substring-after($tx, "/v1/transactions/")
  return (
    test:assert-exists($txid),
    xdmp:document-insert(
      $tdocuri,
      <test>
      <transactionId>{$txid}</transactionId>
      <response>{$response}</response>
      </test>
    )
  )
};

declare function cmrt:commit-transaction ($txid)
{
  let $txuri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/transactions/", $txid, "?result=commit")
  let $response := xdmp:http-post($txuri, $const:xml-options)
  return (
    test:assert-equal('204', xs:string($response/http:code)),
    test:assert-equal('Committed', xs:string($response/http:message))
  )
};

declare function cmrt:rollback-transaction ($txid)
{
  let $txuri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/transactions/", $txid, "?result=rollback")
  let $response := xdmp:http-post($txuri, $const:xml-options)
  return (
    test:assert-equal('204', xs:string($response/http:code)),
    test:assert-equal('Rolled Back', xs:string($response/http:message))
  )
};

(: CASE endpoint specific functions :)

declare function cmrt:create-case ($filename, $options, $txid)
{
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/case?txid=", $txid)
  let $fullpath := fn:concat("/raw/data/", $filename)
  let $file := fn:doc($fullpath)
  return xdmp:http-post($uri, $options, $file)
};

declare function cmrt:get-case ($caseId, $options)
{
  xdmp:http-get(
    fn:concat(
      "http://", $const:RESTHOST, ':', $const:RESTPORT,
      "/v1/resources/case?rs:caseId=", $caseId),
  $options)
};

declare function cmrt:update-case ($caseid, $filename, $options, $txid as xs:string?)
{
  let $transaction :=
    if ($txid)
    then fn:concat("&amp;txid=", $txid)
    else ""
  let $uri := fn:concat(
    "http://", $const:RESTHOST, ':', $const:RESTPORT,
    "/v1/resources/case?rs:caseId=", $caseid, $transaction)
  let $fullpath := fn:concat("/raw/data/", $filename)
  let $file := fn:doc($fullpath)
  return xdmp:http-put($uri, $options, $file)
};

(: Repeated test functions :)

declare function cmrt:get-case-fail ($caseId, $options)
{
  let $response := cmrt:get-case($caseId, $options)
  return (
    test:assert-equal('200', xs:string($response[1]/http:code)),
    test:assert-equal('FAILURE', xs:string($response[2]/ext:readResponse/ext:outcome)),
    test:assert-equal(fn:concat('caseId ', $caseId, ' not found'), xs:string($response[2]/ext:readResponse/ext:details))
  )
};
