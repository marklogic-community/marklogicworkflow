xquery version "1.0-ml";

module namespace clib="http://marklogic.com/casemanagement/case-lib";

import module namespace const = "http://marklogic.com/casemanagement/case-constants" at "/casemanagement/models/case-constants.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace c="http://marklogic.com/workflow/case";
declare namespace sec = 'http://marklogic.com/xdmp/security';

declare function clib:get-new-id($doc as element()?){
  if (fn:exists($doc/@id))
  then xs:string($doc/@id)
  else wfu:new-workflow-id()
};

declare function clib:get-case-document-uri($case-id as xs:string){
  cts:uri-match(fn:concat($const:case-dir, '*/', $case-id, ".xml"))
};

declare function clib:get-case-document($case-id as xs:string){
  let $uri := clib:get-case-document-uri($case-id)
  return doc($uri)
};

declare function clib:get-case-document-from-activity($activity-id as xs:string){
  cts:search(
    fn:collection($const:case-collection),
    cts:element-attribute-range-query(
      xs:QName("c:activity"), xs:QName("id"), "=", $activity-id) )
};

declare function clib:get-activity-document($activity-id as xs:string){
  let $case := clib:get-case-document-from-activity($activity-id)
  return $case/c:case/c:phases/c:phase/c:activities/c:activity[@id=$activity-id]
};

declare function clib:insert-case-document($uri as xs:string, $doc as element(), $permissions as element(sec:permission)*) as xs:boolean {
  let $_ := xdmp:document-insert($uri, $doc,
    $permissions,
    (
      xdmp:default-collections(),
      $const:case-collection
    )
  )
  return fn:true()
};

declare function clib:create-case-document($id, $uri as xs:string, $doc as element(), $permissions as element(sec:permission)*) as xs:boolean {
  let $audit := <c:audit-trail>{clib:audit-create("Created", "Lifecycle", "Case Created")}</c:audit-trail>
  let $case-doc :=
    element c:case {
      attribute id { $id },
      (
        $doc/@*[fn:local-name(.) != "id"],
        $doc/*,
        $audit
      )
    }
  return clib:insert-case-document($uri, $case-doc, $permissions)
};

declare function clib:update-activity(
  $original as element(c:activity),
  $update as element(c:activity)
) as element(c:activity)
{
  ( xdmp:log(fn:concat("original:", xdmp:quote($original)), "debug"), xdmp:log(fn:concat("update:", xdmp:quote($update)), "debug"),
  element c:activity { (
    for $attribute in ($original/@*)
    return attribute {name($attribute)} {$attribute},

    let $names := for $t_attr in ($original/@*) return name($t_attr)
    for $attribute in ($update/@*[not(name(.) = ($names))])
    return attribute {name($attribute)} {$attribute},

    for $section in $original/element()
    return typeswitch($section)
      case element(c:data) return
        if (fn:exists($update/c:data/*))
        then $update/c:data
        else $section
      case element(c:status) return
        if (xs:string($section) != xs:string($update/c:status))
        then $update/c:status
        else $section
      case element(c:description) return
        if (xs:string($section) != xs:string($update/c:description))
        then $update/c:description
        else $section
      case element(c:notes) return
        if (xs:string($section) != xs:string($update/c:notes))
        then $update/c:notes
        else $section
      case element(c:results) return
        if (fn:exists($update/c:results/*))
        then $update/c:results
        else $section
      default return
        $section
  ) } )
};

declare function clib:update-document(
  $original as element(c:case),
  $update as element(c:case)
) as element(c:case)
{
  ( xdmp:log(fn:concat("original:", xdmp:quote($original)), "debug"), xdmp:log(fn:concat("update:", xdmp:quote($update)), "debug"),
  element c:case { (
    for $attribute in ($original/@*)
    return attribute {name($attribute)} {$attribute},

    let $names := for $t_attr in ($original/@*) return name($t_attr)
    for $attribute in ($update/@*[not(name(.) = ($names))])
    return attribute {name($attribute)} {$attribute},

    for $section in $original/element()
    return typeswitch($section)
      case element(c:data) return
        if (fn:exists($update/c:data/*))
        then $update/c:data
        else $section
      case element(c:active-phase) return
        if (xs:string($section) != xs:string($update/c:active-phase))
        then $update/c:active-phase
        else $section
      case element(c:phases) return
        if (fn:exists($update/c:phases/*))
        then $update/c:phases (: Assumed that changes to activities dealt with elsewhere... :)
        else $section
      case element(c:attachments) return
        if (fn:exists($update/c:attachments/*))
        then $update/c:attachments
        else $section
      case element(c:status) return
        if (xs:string($section) != xs:string($update/c:status))
        then $update/c:status
        else $section
      case element(c:parent) return
        if (xs:string($section) != xs:string($update/c:parent))
        then $update/c:parent
        else $section
      case element(c:audit-trail) return
        element c:audit-trail {
          $section/c:audit,
          clib:audit-create("Open", "Lifecycle", "Case Updated")
        }
      default return
        $section
  ) } )
};

declare function clib:update-case-document($case-id as xs:string, $update-doc as element(), $permissions as element(sec:permission)*) as xs:boolean {
  let $uri := clib:get-case-document-uri($case-id)
  let $case-doc := doc($uri)
  let $new-doc := clib:update-document($case-doc/*, $update-doc)
  return clib:insert-case-document($uri, $new-doc, ($permissions, xdmp:document-get-permissions($uri)))
};

(:
declare function clib:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  (: TODO don't just blanket replace all data and attachments, replace one by one :)
  (: if data or attachment nodes are blank, leave them as they are - do not replace them with nothing :)
  (: TODO fail if already closed :)
  let $case := clib:case-get($case-id,fn:true())
  return
    if (clib:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        clib:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            clib:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false()
}; :)


declare function clib:audit-create(
  $status as xs:string,
  $eventCategory as xs:string,
  $description as xs:string
) as element(c:audit) {
  <c:audit>
    <c:by>{xdmp:get-current-user()}</c:by>
    <c:when>{fn:current-dateTime()}</c:when>
    <c:category>{$eventCategory}</c:category>
    <c:status>{$status}</c:status>
    <c:description>{$description}</c:description>
  </c:audit>
};

(:
declare private function clib:check-update-in-sequence($case as element(c:case),$updateTag as xs:string) as xs:boolean {
  $updateTag = $case/@c:update-tag
};

declare private function clib:update-tag($case as element(c:case)) {
  if (fn:not(fn:empty($case/@c:update-tag))) then
    xdmp:node-replace($case/@c:update-tag,attribute c:update-tag {
      seclib:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
  else
    xdmp:node-insert-child($case,attribute c:update-tag {
      seclib:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
};

declare function clib:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO don't just blanket replace all data and attachments, replace one by one : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := clib:case-get($case-id,fn:true())
  return
    if (clib:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        clib:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            clib:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false()
};
:)

(:
 : Succeeds and returns true if case successfully updated and closed
 : )
declare function clib:case-close($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO If locked, check it is by current user, fail otherwise : )
  ( : TODO Remove lockedBy, set locked to false : )
  ( : Changes status to closed : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := clib:case-get($case-id,fn:true())
  return
    if (clib:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        clib:update-tag($case), ( : Update this so it cannot be closed twice : )
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(clib:case-get($case-id,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            clib:audit-create($case-id,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
}; :)

declare function clib:decode-permissions ($permissions-pairs as xs:string*, $new-permissions as xs:string)
  as element(sec:permission)*
{
  (: TODO - pick up xdmp:document-get-permissions($uri) :)
  if (fn:exists($permissions-pairs))
  then
    let $perms :=
        for $permissions-string in $permissions-pairs
        let $pair := fn:tokenize($permissions-string, ":")
        return (
          xdmp:log(fn:concat("decode-permissions got:",$permissions-string)),
          xdmp:permission($pair[1], $pair[2])
        )
    return (
      xdmp:log(fn:concat("permissions:", xdmp:quote($perms))),
      xdmp:default-permissions(),
      $const:case-permissions,
      $perms
    )
  else
    if ("true" = $new-permissions)
    then (
      xdmp:log("No permissions, new - returning default"),
      xdmp:default-permissions(),
      $const:case-permissions,
      (: xdmp:permission("workflow-status",("read")), :) (: WARNING DO NOT UNCOMMENT - reading should be wrapped and amped to prevent data leakage :)
      xdmp:permission("case-user",("read")) (: TODO replace this with the EXACT user, dynamically, as required :)
    )
    else xdmp:log("No permissions, update - returning empty")
};
