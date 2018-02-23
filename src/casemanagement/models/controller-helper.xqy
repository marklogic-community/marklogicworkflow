xquery version "1.0-ml";

module namespace ch="http://marklogic.com/casemanagement/controller-helper";

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace patch="http://marklogic.com/casemanagement/patch-lib" at "/casemanagement/models/patch-lib.xqy";
import module namespace const = "http://marklogic.com/casemanagement/case-constants" at "/casemanagement/models/case-constants.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import schema namespace rapi = "http://marklogic.com/rest-api" at "restapi.xsd";

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
  $input-data as element()?,     (: is there data? :)
  $input-expected as xs:boolean, (: should there be data? :)
  $patches-expected as xs:boolean,
  $activityid as xs:string?
) as map:map { (
  xdmp:log("in ch:validate-data", "debug"),
  xdmp:log(
    fn:concat(
      "data: ", if (fn:exists($input-data)) then "true" else "false",
      " expected: ", if ($input-expected) then "true" else "false",
      " patches: ", if ($patches-expected) then "true" else "false",
      " $activityid=", $activityid
    ), "debug"),
  map:new((
    if (
      (($input-expected) and (fn:exists($input-data)))
        or fn:not($input-expected) (: and fn:not($input-data)) - ignore input data if not expected :)
    )
    then
      if ($patches-expected)
      then
        let $error-list := json:array()
        let $converted := patch:convert-xml-patch($activityid, $input-data, $error-list)
          return
            if (json:array-size($error-list))
            then (
              map:entry("status-code", 405),
              map:entry("response-message", "Validation exception"),
              map:entry("error-detail", fn:string-join(json:array-values($error-list, fn:true()), "; "))
            )
            else (
              map:entry("status-code", 200),
              map:entry("response-message", "OK"),
              map:entry("patches", $converted)
            )
      else (
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
  $new-activity as xs:boolean,   (: is this activity new? :)
  $patches as element(rapi:patch)?
) as map:map {
  map:new((
    map:entry("caseId", $caseid),
    map:entry("phaseId", $phaseid),
    map:entry("activityId", $activityid),
    if (fn:not(fn:empty($patches)))
    then map:entry("patches", $patches)
    else (),
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
            map:entry("error-detail", fn:concat("activityId ", $activityid, " not found"))
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
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params), " input-data:", xdmp:quote($input-data)) , "debug" )
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
  let $patches-expected :=
    if ("true" = xs:string($action/c:data/c:patches-expected))
    then fn:true()
    else fn:false()
  let $caseid :=
    if (map:contains($params, "caseId"))
    then map:get($params, "caseId")
    else
      if ($new-case)
      then clib:get-new-id($input-data)
      else ()

  let $_ := xdmp:log(fn:concat("new-case:", xdmp:quote($new-case),
    " input-expected:", xdmp:quote($input-expected)
    , " patches-expected:", xdmp:quote($patches-expected)) , "debug" )

  let $activityid :=
    if (map:contains($params, "activityId"))
    then map:get($params, "activityId")
    else ()
  let $validation-map :=
    if (($caseid) or (fn:exists($action/c:case/c:case-exists)))
    then ch:validate($caseid, $new-case, fn:exists($input-data), $input-expected)
    else ch:validate-data($input-data, $input-expected, $patches-expected, $activityid)
  return (: validation for caseactivity :)
    (xdmp:log(fn:concat("validation-map:", xdmp:quote($validation-map)), "debug"),
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
        if ($activityid)
        then $activityid
        else
          if ($new-activity)
          then clib:get-new-id($input-data)
          else ()
        let $validation-map := ch:validate-activity($caseid, $phaseid, $activityid, $new-activity, map:get($validation-map, "patches"))
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
    )
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

declare function ch:case-update($case-id as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:boolean {
  clib:update-case-document($case-id, $data, $permissions)
};

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
  let $_log := xdmp:log(fn:concat("caseactivity-update called on activity ", $activity-id, " update=", xdmp:quote($updates)))
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

declare function ch:caseactivity-patch(
  $activity-id as xs:string,
  $patches as element(rapi:patch)?
) (: as xs:string :) {
  let $_log := xdmp:log(fn:concat("caseactivity-patch called on activity ", $activity-id, " patches=", xdmp:quote($patches)))
  let $case := clib:get-case-document-from-activity($activity-id)

  let $error-list := json:array()
  let $_ := xdmp:log(fn:concat("patches ", xdmp:quote($patches)), "debug")
  let $is-content-patched :=
    (
      let $is-patched := patch:apply-patch(
        $case, $patches, $error-list
      )
      return
        if (json:array-size($error-list) gt 0)
        then error((), "RESTAPI-SRVEXERR", (
          405, concat("Invalid content patch for activity ", $activity-id),
          fn:string-join(json:array-values($error-list, fn:true()), "; ")
        ))
        else $is-patched
    )

  return ($is-content-patched, $patches)
};
