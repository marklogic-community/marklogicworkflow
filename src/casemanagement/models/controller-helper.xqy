xquery version "1.0-ml";

module namespace ch="http://marklogic.com/casemanagement/controller-helper";

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace const = "http://marklogic.com/casemanagement/case-constants" at "/casemanagement/models/case-constants.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace c="http://marklogic.com/workflow/case";

declare function ch:validate(
  $caseid as xs:string?,         (: should always be supplied - new case will supply new id :)
  $new-case as xs:boolean,       (: is this case new? :)
  $input-data as xs:boolean,     (: is there data? :)
  $input-expected as xs:boolean  (: should there be data? :)
) as map:map {
  map:new((
    map:entry("caseId", $caseid),
    xdmp:log("in ch:validate", "debug"),
    (: supplied caseid ? :)
    if (fn:empty($caseid))
    then (
      map:entry("status-code", 404),
      map:entry("response-message", "Case not found"),
      map:entry("error-detail", "caseId parameter is required")
    )
    else
      let $case-count := fn:count( clib:get-case-document-uri($caseid) )
      return
      (: ( case exists AND new-case FALSE) OR ( case does not exist AND new-case TRUE) :)
        if ( (($case-count) and (fn:not($new-case))) or ((xs:int("0") = $case-count) and ($new-case)) )
        then
        (: what to validate :)
          if (
            (($input-expected) and ($input-data))
              or fn:not($input-expected) (: and fn:not($input-data)) - ignore input data if not expected :)
          )
          then (
            map:entry("status-code", 200),
            map:entry("response-message", "OK")
          )
          else (
            map:entry("status-code", 405),
            map:entry("response-message", "Invalid input"),
            if ($new-case)
            then map:entry("error-detail", "Nothing to insert")
            else map:entry("error-detail", "Nothing to update")
          )
        else
          if ($new-case)
          then (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("caseId ", $caseid, " exists"))
          )
          else (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("caseId ", $caseid, " not found"))
          )
  ))
};

declare function ch:validate-data(
  $input-data as xs:boolean,     (: is there data? :)
  $input-expected as xs:boolean  (: should there be data? :)
) as map:map { (
  xdmp:log("in ch:validate-data", "debug"),
  map:new((
    if (
      (($input-expected) and ($input-data))
        or fn:not($input-expected) (: and fn:not($input-data)) - ignore input data if not expected :)
    )
    then (
      map:entry("status-code", 200),
      map:entry("response-message", "OK")
    )
    else (
      map:entry("status-code", 405),
      map:entry("response-message", "Validation exception"),
      map:entry("error-detail", "Nothing to update")
    )
  )) )
};

declare function ch:validate-activity(
  $caseid as xs:string?,
  $phaseid as xs:string?,
  $activityid as xs:string?,     (: should always be supplied - new activity will supply new id :)
  $new-activity as xs:boolean    (: is this activity new? :)
) as map:map {
  map:new((
    map:entry("caseId", $caseid),
    map:entry("phaseId", $phaseid),
    map:entry("activityId", $activityid),
    xdmp:log("in ch:validate-activity", "debug"),
    (: supplied activityid ? :)
    if (fn:empty($activityid))
    then (
      map:entry("status-code", 404),
      map:entry("response-message", "Activity not found"),
      map:entry("error-detail", "activityId parameter is required")
    )
    else
      (: check if activity already exists : )
      let $case := clib:get-case-document($caseid)
      let $activity-exists := fn:exists($case/c:case/c:phases/c:phase/c:activities/c:activity[@id=$activityid]) :)
      let $activity-exists :=
        xdmp:estimate(
          cts:search(
            fn:collection($const:case-collection),
            cts:element-attribute-range-query(
              xs:QName("c:activity"), xs:QName("id"), "=", $activityid) )
        )
      return
        if ($activity-exists)
        then
          if ($new-activity)
          then (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("activityId ", $activityid, " exists"))
          )
          else (
            map:entry("status-code", 200),
            map:entry("response-message", "OK")
          )
        else (: activity doesn't exist :)
          if ($new-activity)
          then (
            map:entry("status-code", 200),
            map:entry("response-message", "OK")
          )
          else (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("caseId ", $caseid, " not found"))
          )
  ))
};

declare function ch:validate-permissions($valid as map:map, $permissions-string as xs:string*, $new-permissions as xs:string) {
  try {
    let $_perms := map:put($valid, "permissions", clib:decode-permissions($permissions-string, $new-permissions))
    return $valid
  }
  catch ($exception) {
    map:new((
      map:entry("status-code", 405),
      map:entry("response-message", "Invalid input"),
      map:entry("error-detail", xs:string($exception/error:message))
    ))
  }
};

declare function ch:validation(
  $action-name as xs:string,
  $params as map:map?,
  $input-data as element()?
) as map:map {
  (: TODO - fix this: create single validation routine :)
  (:
   : 4 functions
   : - validate case
   : - validate activity
   : - validate data
   : - validate permissions
   : return ids & permissions
   :)
  let $action := $const:validation/c:action[@name = $action-name]
  let $_ := xdmp:log(fn:concat("validation action name:", $action-name, " action:", xdmp:quote($action)) , "debug" )
  let $new-case :=
    if (fn:exists($action/c:case/c:case-exists))
    then
      if ("true" = xs:string($action/c:case/c:case-exists))
      then fn:false()
      else fn:true()
    else fn:false()
  let $input-expected :=
    if ("true" = xs:string($action/c:data/c:data-expected))
    then fn:true()
    else fn:false()
  let $caseid :=
    if (map:contains($params, "caseId"))
    then map:get($params, "caseId")
    else
      if ($new-case)
      then clib:get-new-id($input-data)
      else ()

  let $validation-map :=
    if (($caseid) or (fn:exists($action/c:case/c:case-exists)))
    then ch:validate($caseid, $new-case, fn:exists($input-data), $input-expected)
    else ch:validate-data(fn:exists($input-data), $input-expected)
  return (: validation for caseactivity :)
    if ( (200 = map:get($validation-map, "status-code")) and (fn:exists($action/c:activity)))
    then
      let $new-activity :=
        if ("true" = xs:string($action/c:activity/c:activity-exists))
        then fn:false()
        else fn:true()
      let $phaseid :=
        if (map:contains($params, "phaseId"))
        then map:get($params, "phaseId")
        else
          if ($new-activity)
          then clib:get-new-id(())
          else ()
      let $activityid :=
        if (map:contains($params, "activityId"))
        then map:get($params, "activityId")
        else
          if ($new-activity)
          then clib:get-new-id($input-data)
          else ()
        let $validation-map := ch:validate-activity($caseid, $phaseid, $activityid, $new-activity)
      return
        if (map:contains($validation-map, "status-code"))
        then $validation-map
        else
          map:new((
            map:entry("status-code", 500),
            map:entry("response-message", "Internal error"),
            map:entry("error-detail", "Unable to process caseactivity")
          ))

    else
      if (
        (200 = map:get($validation-map, "status-code"))
          and (fn:exists($action/c:permissions/c:new-permissions)))
      then ch:validate-permissions($validation-map, map:get($params, "permission"), xs:string($action/c:permissions/c:new-permissions))
      else
        if (map:contains($validation-map, "status-code"))
        then $validation-map
        else
          map:new((
            map:entry("status-code", 500),
            map:entry("response-message", "Internal error"),
            map:entry("error-detail", "Unable to process")
          ))
};

(:
 : Create a new process and activate it.
 :)
declare function ch:case-create($id, $case-template-name as xs:string, $data as element(c:case), $permissions as element(sec:permission)*, $parent as xs:string?) as xs:string {
  let $uri := fn:concat($const:case-dir, $case-template-name, "/", $id, ".xml")
  (: need to ensure that the id is added as an attribute :)
  let $_ := xdmp:log(fn:concat("creating case for id:", $id, ", uri:", $uri), "debug")
  let $_ := clib:create-case-document($id, $uri, $data, $permissions)
  return $id
};
(:
declare function ch:case-create($case-template-name as xs:string,$data as element()*,$attachments as element()*,$parent as xs:string?) as xs:string {
  let $id := sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
  let $uri := "/casemanagement/cases/"||$case-template-name||"/"||$id || ".xml"
  let $doc := <c:case id="{$id}">
    <c:data>{$data}</c:data>
    <c:attachments>{$attachments}</c:attachments>
    <c:audit-trail>{m:audit-create($id,"Created","Lifecycle","Case Created",($data,$attachments))}</c:audit-trail>
    <c:metrics></c:metrics>

    <c:status>Open</c:status>
    <c:locked>{fn:false()}</c:locked>

    <c:case-template-name>{$case-template-name}</c:case-template-name>
    {if (fn:not(fn:empty($parent))) then <c:parent>{$parent}</c:parent> else ()}
  </c:case>
  let $_ := ch:createCaseDocument($uri,$doc)
  return $id
};
:)



(:
declare private function ch:check-update-in-sequence($case as element(c:case),$updateTag as xs:string) as xs:boolean {
  $updateTag = $case/@c:update-tag
};

declare private function ch:update-tag($case as element(c:case)) {
  if (fn:not(fn:empty($case/@c:update-tag))) then
    xdmp:node-replace($case/@c:update-tag,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
  else
    xdmp:node-insert-child($case,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
};

declare function ch:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {
:)
declare function ch:case-update($case-id as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:boolean {
  clib:update-case-document($case-id, $data, $permissions)
  (:
  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO don't just blanket replace all data and attachments, replace one by one : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := ch:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        ch:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            ch:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false() :)
};

(:
 : Default is to not lock for update (read only)
 : Returns true is locked, or if read succeeds without a need for a lock (i.e. lock wasn't requested)
 : )
declare function ch:case-get($case-id as xs:string, $lock-for-update as xs:boolean?) as element(c:case)? {
  ( : TODO - REMOVE! deprecated by clib:get-case-document : )
  ( :  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute") : )
  let $case := clib:get-case-document($case-id)
  return
    if ($case)
    then $case
    else
      let $dir := "/casemanagement/cases/"
      let $uri := clib:get-case-document-uri($case-id)
      return cts:search(
        fn:collection($const:case-collection),
        ( : cts:and-query(( : )
        ( :  cts:directory-query($dir, "infinity"), : )
        cts:document-query($uri)
        ( : )) : )
      )/c:case[1]
  ( : TODO add audit entry item : )
  ( : TODO add locked audit entry item too : )
}; :)

(:
 : Succeeds and returns true if case successfully updated and closed
 : )
declare function ch:case-close($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO If locked, check it is by current user, fail otherwise : )
  ( : TODO Remove lockedBy, set locked to false : )
  ( : Changes status to closed : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := ch:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        ch:update-tag($case), ( : Update this so it cannot be closed twice : )
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(m:case-get($case-id,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            ch:audit-create($case-id,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
}; :)


declare function ch:caseactivity-create(
  $case-id as xs:string,
  $phase-id as xs:string,
  $activity-id as xs:string,
  $activity as element(c:activity)
) as xs:string {
  let $_log := xdmp:log(fn:concat("caseactivity-create called on case ", $case-id))
  let $case := clib:get-case-document($case-id)
  (: TODO - check whether to insert the activity id too :)
  let $_insert :=
    if ($case/c:case/c:phases/c:phase[@id=$phase-id])
    then (
      xdmp:log(fn:concat("update phase ", $phase-id, " with activity ", $activity-id)),
      xdmp:node-insert-child(
        $case/c:case/c:phases/c:phase[@id=$phase-id]/c:activities,
        $activity),
      xdmp:node-insert-child(
        $case/c:case/c:audit-trail,
        clib:audit-create("Open", "Lifecycle", fn:concat("Case Activity ", $activity-id, " Inserted"))
      )
    )
    else (
      xdmp:log(fn:concat("new phase ", $phase-id, " with activity ", $activity-id)),
      xdmp:node-insert-child(
        $case/c:case/c:phases,
        element c:phase {
          attribute id { $phase-id },
          element c:activities {
            $activity }
        } ),
      xdmp:node-insert-child(
        $case/c:case/c:audit-trail,
        clib:audit-create("Open", "Lifecycle", fn:concat("Case Activity ", $activity-id, " Inserted"))
      )
    )
  return $activity-id
};

declare function ch:caseactivity-update(
  $activity-id as xs:string,
  $updates as element(c:activity)
) as xs:string {
  let $_log := xdmp:log(fn:concat("caseactivity-update called on activity ", $activity-id))
  let $case := clib:get-case-document-from-activity($activity-id)
  let $current-activity := $case/c:case/c:phases/c:phase/c:activities/c:activity[@id=$activity-id]
  let $updated-activity := clib:update-activity($current-activity, $updates)
  let $_update := (
      xdmp:node-replace(
        $current-activity,
        $updated-activity),
      xdmp:node-insert-child(
        $case/c:case/c:audit-trail,
        clib:audit-create("Open", "Lifecycle", fn:concat("Case Activity ", $activity-id, " Updated"))
      )
  )
  return $activity-id
};

