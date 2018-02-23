xquery version "1.0-ml";

module namespace patch="http://marklogic.com/casemanagement/patch-lib";

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace docmodupd = "http://marklogic.com/rest-api/models/document-model-update" at "/MarkLogic/rest-api/models/document-model-update.xqy";
import module namespace replib = "http://marklogic.com/rest-api/lib/replace-lib" at "/MarkLogic/rest-api/lib/replace-lib.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";

declare namespace c="http://marklogic.com/workflow/case";
declare option xdmp:mapping "false";

(:
 : ideally replace with standard library docmodupd:convert-xml-patch in the future
 :)

declare private function patch:test-path(
  $document        as document-node(),
  $path            as xs:string,
  $namespaces      as map:map,
  $error-list      as json:array?
)
{
  let $pathstr := fn:concat("$document", $path)
  return
    if ( xdmp:value ( $pathstr, $namespaces ) )
    then ()
    else docmodupd:push-error($error-list, "invalid path: "||$path)
};

declare private function patch:node-insert-position(
  $operation as element()
) as xs:string
{
  let $position := $operation/@position/string(.)
  return
    if (empty($position))
    then "last-child"
    else $position
};

declare private function patch:is-insert-position-valid(
  $position   as xs:string?,
  $error-list as json:array?
) as xs:boolean
{
  if ($position = ("before","after","last-child"))
  then true()
  else (
    if (exists($position))
    then docmodupd:push-error($error-list,"insert with unknown position: "||$position)
    else docmodupd:push-error($error-list,"insert without position"),

    false()
  )
};

declare function patch:convert-path(
  $activityid as xs:string,
  $raw-path   as xs:string,
  $error-list as json:array?
) as xs:string? {
(:
   : modify
   :      /c:activity
   : to
   :      /c:case/c:phases/c:phase/c:activities/c:activity[@id=$activity-id]
   :)
  let $dblquote := '"'
  let $_ := xdmp:log(fn:concat("patch:convert-path got $activityid=", $activityid, ", $raw-path=", $raw-path))
  let $activity-path :=
    fn:concat(
      "/c:case/c:phases/c:phase/c:activities/c:activity[@id=",
      $dblquote,
      $activityid,
      $dblquote,
      "]"
    )
  let $path :=
    if (starts-with($raw-path, "/c:activity") )
    then
      fn:replace(
        $raw-path,
        "/c:activity",
        $activity-path
      )
    else
      if (starts-with($raw-path, "//"))
      then concat($activity-path, $raw-path)
      else ()
  return
    if (($path) and (cts:valid-index-path($path, true())))
    then $path
    else
      if ($path)
      then docmodupd:push-error($error-list,"invalid path: "||$path)
      else docmodupd:push-error($error-list,"unable to interpret path: "||$raw-path)
};

declare function patch:convert-xml-operation(
  $activityid as xs:string,
  $operation  as element(),
  $path-att   as attribute(),
  $error-list as json:array?
) as element()
{
  element {node-name($operation)} {
    $operation/(@* except $path-att),
    attribute {node-name($path-att)} {
      patch:convert-path($activityid, string($path-att), $error-list)
    },
    docmodupd:copy-namespaces($operation),
    $operation/node()
  }
};

declare function patch:convert-xml-patch(
  $activityid as xs:string,
  $raw-patch  as element(rapi:patch),
  $error-list as json:array?
) as element(rapi:patch)
{
  <rapi:patch>{
    docmodupd:copy-namespaces($raw-patch),

    (: safe and absolute operation paths :)
    for $node in $raw-patch/node()
    return
      typeswitch($node)
        case element(rapi:delete) return (
          let $select-okay     :=
            if (exists($node/@select))
            then true()
            else docmodupd:push-error($error-list,"delete without select path")
          return
            if (not($select-okay)) then ()
            else patch:convert-xml-operation($activityid, $node, $node/@select, $error-list)
        )
        case element(rapi:insert) return (
          let $context-okay     :=
            if (exists($node/@context))
            then true()
            else docmodupd:push-error($error-list,"insert without context path")
          let $position-okay    := patch:is-insert-position-valid(
            patch:node-insert-position($node), $error-list
          )
          let $content-okay     :=
            if (exists($node/node()))
            then true()
            else docmodupd:push-error($error-list,"insert without content: "||string($node/@context))
          return
            if (not($context-okay or $position-okay or $content-okay))
            then ()
            else patch:convert-xml-operation($activityid, $node, $node/@context, $error-list)
        )
        case element(rapi:replace) return (
          let $select-okay     :=
            if (exists($node/@select))
            then true()
            else docmodupd:push-error($error-list,"replace without select path")
          let $content-okay     :=
            if (exists($node/node()) or exists($node/@apply))
            then true()
            else docmodupd:push-error($error-list,"replace without apply or content: "||string($node/@select))
          return
            if (not($select-okay or $content-okay)) then ()
            else patch:convert-xml-operation($activityid, $node, $node/@select, $error-list)
        )
        default return $node,
    <rapi:insert position="last-child" context="/c:case/c:audit-trail">{
      clib:audit-create("Open", "Lifecycle", fn:concat("Case Activity ", $activityid, " Patched"))
    }</rapi:insert>
  }</rapi:patch>
};

declare private function patch:lock-uris(
  $uris as xs:string*
) as xs:string*
{
  if (empty($uris)) then ()
  else
    for $uri in $uris
    return (
      xdmp:lock-for-update($uri),
      xdmp:log(fn:concat("Locking ", $uri))
    ),
  $uris
};

declare function patch:apply-patch(
  $document        as document-node(),
  $patch           as element(rapi:patch),
  $error-list      as json:array?
) as xs:boolean
{
  let $patch-content      := ()
  let $function-map       := ()
  let $is-xml             := fn:true()
  let $delete-ops         := $patch/rapi:delete
  let $replace-ops        := $patch/rapi:replace
  let $insert-ops         := $patch/rapi:insert
  let $ns-bindings := map:map()
  let $_bind :=
    for $prefix in in-scope-prefixes($patch)
    let $ns-uri := namespace-uri-for-prefix($prefix,$patch)
    where $prefix ne "xml"
    return
      if ($ns-uri = ("http://marklogic.com/rest-api")) then ()
      else map:put($ns-bindings, $prefix, $ns-uri)

  let $expression := concat("( ",string-join((
    for $delete-op at $i in $delete-ops
    let $path := $delete-op/@select/string(.)
    return
      if (empty($path)) then ()
      else (
        concat(
          "docmodupd:node-delete-operation($is-xml, ",
          "$error-list, ",
          "subsequence($delete-ops,",$i,",1), ",
          "'",string-join(tokenize($path,"'"),"&amp;apos;"),"', ",
          "()", ", ",
          $path,
          ")"
        ),
        patch:test-path($document, $path, $ns-bindings, $error-list)
      ),

    for $replace-op at $i in $replace-ops
    let $path := $replace-op/@select/string(.)
    return
      if (empty($path)) then ()
      else (
        concat(
          "docmodupd:node-replace-operation($is-xml, ",
          "$patch-content, $function-map, $error-list, ",
          "subsequence($replace-ops,",$i,",1), ",
          "'",string-join(tokenize($path,"'"),"&amp;apos;"),"', ",
          "()", ", ",
          $path,
          ")"
        ),
        patch:test-path($document, $path, $ns-bindings, $error-list)
      ),

    for $insert-op at $i in $insert-ops
    let $position := patch:node-insert-position($insert-op)
    let $path     := $insert-op/@context/string(.)
    return
      if (empty($path)) then ()
      else (
        concat(
          "docmodupd:node-insert-",$position,"-operation($is-xml, ",
          "$patch-content, $function-map, $error-list, ",
          "subsequence($insert-ops,",$i,",1), ",
          "'",string-join(tokenize($path,"'"),"&amp;apos;"),"', ",
          "()", ", ",
          $path,
          ")"
        ),
        patch:test-path($document, $path, $ns-bindings, $error-list)
      )

  ),", "),
    " )")

  return
    if (json:array-size($error-list) gt 0)
    then fn:false()
    else
      try {
        exists(
          if (empty($ns-bindings))
          then $document/xdmp:value($expression)
          else xdmp:with-namespaces(
            $ns-bindings,
            $document/xdmp:value($expression)
          )
        )
      } catch($e) {
        if ($e/error:code eq "XDMP-UNEXPECTED")
        then error((), "RESTAPI-INVALIDCONTENT",
          (405, "Invalid content patch", $e/error:code))
        else xdmp:rethrow()
      }
};
