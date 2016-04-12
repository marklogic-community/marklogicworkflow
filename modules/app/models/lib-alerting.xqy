xquery version "1.0-ml";

module namespace ss = "http://marklogic.com/alerts/alerting";

import module namespace alert="http://marklogic.com/xdmp/alert" at "/MarkLogic/alert.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare namespace my="http://marklogic.com/alerts";

declare variable $SAVE-SEARCH-MODULE := "/app/models/save-search.xqy";
declare variable $CREATE-ACTION-MODULE := "/app/models/create-action.xqy";
declare variable $CREATE-RULE-NOTIFY-MODULE := "/app/models/create-rule-notify.xqy";
declare variable $CREATE-RULE-MODULE := "/app/models/create-rule.xqy";
declare variable $CREATE-CONFIG-MODULE := "/app/models/create-config.xqy";
declare variable $CPF-ENABLE-MODULE := "/app/models/cpf-enable.xqy";
declare variable $CONFIG-SET-CPF-DOMAIN-NAMES-MODULE := "/app/models/config-set-cpf-domain-names.xqy";
declare variable $CONFIG-SET-CPF-DOMAIN-NAMES-INSERT-MODULE := "/app/models/config-set-cpf-domain-names-insert.xqy";
declare variable $CONFIG-DELETE-MODULE := "/app/models/config-delete.xqy";
declare variable $GET-DOMAIN-MODULE := "/app/models/get-domain.xqy";
declare variable $REMOVE-DOMAIN-MODULE := "/app/models/remove-domain.xqy";
declare variable $CONFIGURE-DOMAIN-MODULE := "/app/models/configure-domain.xqy";

declare function ss:create-collection-search($collection as xs:string)  {
  cts:collection-query($collection)
};

(: Default search grammar :)
declare function ss:create-basic-search($query as xs:string)  {
  search:parse($query)
};

(: same as from lib-adhoc-alerts.xqy - lon/lat/radius :)
declare function ss:create-geo-near-search($ns as xs:string,$elname as xs:string, $latattr as xs:string,$lonattr as xs:string,
    $lat as xs:double,$lon as xs:double, $radiusmiles as xs:double)  {
  cts:element-geospatial-query(fn:QName($ns,$elname),cts:circle($radiusmiles, cts:point($lat, $lon)))
};

declare function ss:save-search($searchdoc, $searchname as xs:string) as xs:string {
  (: use current user on app server :)
  let $search-uri-user := fn:concat("/config/search/",xdmp:get-current-user(),"/",$searchname,".xml")
  let $l := xdmp:log($search-uri-user)
  let $result := xdmp:document-insert($search-uri-user,
    element ss:saved-search {
      attribute name {$searchname},
      attribute uri {$search-uri-user},
      $searchdoc
    }
    ,xdmp:default-permissions(),
    (xdmp:default-collections(),"saved-search")
  )
  return $search-uri-user
};

declare function ss:save-shared-search($searchdoc, $searchname as xs:string) as xs:string {
  let $search-uri-shared := fn:concat("/config/search/shared/",$searchname,".xml")
  let $result := xdmp:document-insert($search-uri-shared,
    element ss:saved-search {
      attribute name {$searchname},
      attribute uri {$search-uri-shared},
      $searchdoc
    }
    ,xdmp:default-permissions(),
    (xdmp:default-collections(),"saved-search")
  )
  return $search-uri-shared
};

declare function ss:get-saved-searches() {
  cts:search(fn:collection("saved-search"),cts:directory-query(fn:concat("/config/search/",xdmp:get-current-user(),"/"),"1"))/ss:saved-search
};

declare function ss:get-shared-searches() {
  cts:search(fn:collection("saved-search"),cts:directory-query("/config/search/shared/","1"))/ss:saved-search
};

declare function ss:delete-search($searchname) {
  let $search-uri-user := fn:concat("/config/search/",xdmp:get-current-user(),"/",$searchname,".xml")
  return xdmp:document-delete($search-uri-user)
};

declare function ss:delete-shared-search($searchname) {
  let $search-uri-shared := fn:concat("/config/search/shared/",$searchname,".xml")
  return xdmp:document-delete($search-uri-shared)
};

declare function ss:unsubscribe-and-delete-shared-search($searchname,$notificationurl) {
  (ss:unsubscribe($searchname,$notificationurl),ss:delete-shared-search($searchname))
};

declare function ss:unsubscribe-and-delete-search($searchname,$notificationurl) {
  (ss:unsubscribe($searchname,$notificationurl),ss:delete-search($searchname))
};

declare function ss:save-subscribe-search($searchdoc as cts:query,$searchname as xs:string,$notificationurl as xs:string,$alert-detail as xs:string?,$content-type as xs:string?) {
  (: use current user on app server :)
  (xdmp:invoke($SAVE-SEARCH-MODULE,
      (xs:QName("my:searchdoc"),$searchdoc,xs:QName("my:searchname"),$searchname),
      <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
    )
    ,ss:do-subscribe-check($notificationurl,$searchname,$alert-detail,$content-type)
  )
};

(: call the following from eval - different-transaction :)
declare function ss:do-save($searchdoc as cts:query,$searchname as xs:string) {
  xdmp:document-insert(fn:concat("/config/search/",xdmp:get-current-user(),"/",$searchname,".xml"), document {$searchdoc} (: why not just this search doc? :)
    ,xdmp:default-permissions(),
    (xdmp:default-collections(),"saved-search") )
};

declare function ss:subscribe($searchname as xs:string,$notificationurl as xs:string,$alert-detail as xs:string?,$content-type as xs:string?) as xs:boolean {
  ss:do-subscribe-check($notificationurl,$searchname,$alert-detail,$content-type)
};

declare function ss:unsubscribe($searchname,$notificationurl) as xs:boolean {
  (: NB supports multiple notification URLs. i.e. multiple UIs on same DB for same user :)
  ss:do-unsubscribe($notificationurl,$searchname)
};

(: This function intended to be called within a REST server - i.e. known DB
 : Alert detail can be 'full' or 'snippet' which means either the full doc within the alert info container, or just the snippet information within the alert info container.
 :)
declare function ss:do-subscribe-check($notificationurl as xs:string,$searchname as xs:string,$alert-detail as xs:string?,$content-type as xs:string?) as xs:boolean {
  ss:do-subscribe($notificationurl,"/modules/alert-generic-messaging.xqy",($alert-detail,"full")[1],($content-type,"application/json")[1],$searchname,"generic-alert-domain","rest-sitaware-modules",
    cts:query((fn:doc(fn:concat("/config/search/",xdmp:get-current-user(),"/",$searchname,".xml"))/element(),fn:doc(fn:concat("/config/search/shared/",$searchname,".xml"))/element())[1] )
  )
};

declare function ss:do-add-action-rule($alert-name as xs:string,$notificationurl as xs:string,$alert-module as xs:string?,$alert-detail as xs:string,$content-type as xs:string,$searchname as xs:string,$cpf-domain as xs:string,$dbname as xs:string,$searchdoc as cts:query?) as xs:boolean {

  let $e2 := xdmp:invoke(
    $CREATE-ACTION-MODULE,
    (xs:QName("my:alert-name"),$alert-name,xs:QName("my:alert-module"),$alert-module,xs:QName("my:dbname"),$dbname),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
  let $e3 := xdmp:invoke(
    $CREATE-RULE-NOTIFY-MODULE,
    (xs:QName("my:alert-name"),$alert-name,xs:QName("my:alert-detail"),$alert-detail,xs:QName("my:content-type"),$content-type,xs:QName("my:notificationurl"),$notificationurl,
     xs:QName("my:searchname"),$searchname,xs:QName("my:searchdoc"),$searchdoc),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
  return fn:true()
};

declare function ss:do-subscribe($notificationurl as xs:string,$alert-module as xs:string?,$alert-detail as xs:string,$content-type as xs:string,$searchname as xs:string,$cpf-domain as xs:string,$dbname as xs:string,$searchdoc as cts:query?) as xs:boolean {
  let $alert-name := xdmp:invoke(
    $CREATE-CONFIG-MODULE,
    (xs:QName("my:shortname"),$searchname),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
  let $e2 := ss:do-add-action-rule($alert-name,$notificationurl ,$alert-module,$alert-detail,$content-type,$searchname,$cpf-domain,$dbname,$searchdoc)
  let $e4 := xdmp:invoke(
    $CPF-ENABLE-MODULE,
    (xs:QName("my:alert-name"),$alert-name,xs:QName("my:cpf-domain"),$cpf-domain),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
  let $log := xdmp:log(fn:concat("SUBSCRIBE LOGS: ",$alert-name,$e2,$e4))
  return fn:true()
};

declare function ss:do-unsubscribe($notificationurl as xs:string,$searchname as xs:string) as xs:boolean {
  let $alert-name := fn:concat("/config/alerts/",xdmp:get-current-user(),"/",$searchname,"/",$notificationurl)

  let $rr :=
    for $rule in alert:get-all-rules($alert-name,cts:collection-query($alert-name))
    return
      alert:rule-remove($alert-name,$rule/@id)

  let $l := xdmp:invoke(
    $CONFIG-SET-CPF-DOMAIN-NAMES-MODULE,
    (xs:QName("my:alert-name"),$alert-name),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
  return fn:true()
};

declare function ss:create-rule-notify($alert-name as xs:string,$alert-detail as xs:string,$content-type as xs:string,
  $notificationurl as xs:string,$searchname as xs:string,$searchdoc as cts:query) {

  ss:create-rule($alert-name,(:)$notificationurl,:) $searchdoc,(
    element notificationurl {$notificationurl},
    element searchname {$searchname},
    element detail {$alert-detail},
    element contenttype {$content-type}
  ))
};

declare function ss:get-alert($shortname as xs:string) as element(alert:config)? {
  alert:config-get($shortname)
};


declare function ss:do-create-config($shortname as xs:string) as xs:string {
  let $rem := ss:check-remove-config($shortname)
  return
  xdmp:invoke(
    $CREATE-CONFIG-MODULE,
    (xs:QName("my:shortname"),$shortname),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
};

declare function ss:do-create-rule($alert-name as xs:string,$query as cts:query,$options as element()*) as empty-sequence() {
  xdmp:invoke(
    $CREATE-RULE-MODULE,
    (xs:QName("my:alert-name"),$alert-name,xs:QName("my:query"),$query (:,xs:QName("my:options"),($options) :) ),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
};

declare function ss:do-create-action($alert-name as xs:string,$alert-module as xs:string,$dbname as xs:string?,$options as element()*) {
  xdmp:invoke(
    $CREATE-ACTION-MODULE,
    (xs:QName("my:alert-name"),$alert-name,xs:QName("my:alert-module"),$alert-module,xs:QName("my:dbname"),$dbname,xs:QName("my:options"),($options)),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
};

declare function ss:check-remove-config($shortname as xs:string) {
  let $alert-name := "/config/alerts/" || $shortname
  let $config := alert:config-get($alert-name)
  return
    if (fn:not(fn:empty($config))) then
      (: Check if config used in a cpf domain, if so remove it from that domain :)
      let $unreg := xdmp:invoke($CONFIG-SET-CPF-DOMAIN-NAMES-INSERT-MODULE,
        (xs:QName("my:alert-name"),$alert-name),
        <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
      )
      (: Do this for each domain - NA all done in one hit:)
      (: Now remove the alert config :)
      return xdmp:invoke($CONFIG-DELETE-MODULE,
        (xs:QName("my:alert-name"),$alert-name),
        <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
      )
    else ()
};

declare function ss:create-config($shortname as xs:string) as xs:string {
  (: add alert :)
  let $alert-name := "/config/alerts/" || $shortname
  let $config := alert:make-config(
        $alert-name,
        $alert-name || " configuration",
        $alert-name || " configuration",
          <alert:options></alert:options> )
  let $config-out := alert:config-insert($config)
  return $alert-name
};

declare function ss:cpf-enable($alert-name as xs:string,$cpf-domain as xs:string) {
  alert:config-insert(
    alert:config-set-cpf-domain-names(
      alert:config-get($alert-name),
      ($cpf-domain)))
};

declare function ss:create-domain($domainname as xs:string,$domaintype as xs:string,$domainpath as xs:string,$domaindepth as xs:string,$pipeline-names as xs:string*,$modulesdb as xs:string) as xs:unsignedLong {

    (: check if domain already exists and recreate :)
    let $remove :=
      try {
        if (fn:not(fn:empty(
          xdmp:invoke($GET-DOMAIN-MODULE,
            (xs:QName("my:processmodeluri"),$domainname),
            <options xmlns="xdmp:eval">
              <database>{xdmp:triggers-database()}</database>
              <isolation>different-transaction</isolation>
            </options>
          )
        ))) then
          let $_ := xdmp:log(" GOT DOMAIN TO REMOVE")
          return
            xdmp:invoke($REMOVE-DOMAIN-MODULE,
              (xs:QName("my:processmodeluri"),$domainname),
              <options xmlns="xdmp:eval">
                <database>{xdmp:triggers-database()}</database>
                <isolation>different-transaction</isolation>
              </options>
            )
        else
          ()
      } catch ($e) { ( xdmp:log("Error trying to remove domain: " || $domainname),xdmp:log($e) ) } (: catching domain throwing error if it doesn't exist. We can safely ignore this :)

    (: Configure domain :)
    return
      xdmp:invoke($CONFIGURE-DOMAIN-MODULE,
        (xs:QName("my:otherpipeline"),($pipeline-names[2]),xs:QName("my:mdb"),xdmp:database($modulesdb),xs:QName("my:pname"),$domainname,
         xs:QName("my:type"),$domaintype,xs:QName("my:path"),$domainpath,xs:QName("my:depth"),$domaindepth
        ),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      ) (: end eval :)

};

declare function ss:add-alert($shortname as xs:string,$query as schema-element(cts:query),
  $ruleoptions as element()*,$module as xs:string,$moduledb as xs:unsignedLong,$actionoptions as element()*) as xs:string {
  let $name := ss:do-create-config($shortname)
  return
    (
      ss:do-create-rule($name,$query,$ruleoptions),
      ss:do-create-action($name,$module,$moduledb,$actionoptions),
      $name
    )
};

declare function ss:create-rule($alert-name as xs:string,$query as cts:query,$options as element()*) {
  let $rule := alert:make-rule(
      fn:concat($alert-name,"-rule"),
      $alert-name || " rule",
      0, (: equivalent to xdmp:user(xdmp:get-current-user()) :)
      $query,
      fn:concat($alert-name,"-action"),
      <alert:options>
        {
          $options
        }
      </alert:options> )
  return alert:rule-insert($alert-name, $rule)
};

declare function ss:create-action($alert-name as xs:string,$alert-module as xs:string,$db as xs:string,$options as element()*) {
  let $action := alert:make-action(
      fn:concat($alert-name,"-action"),
      $alert-name || " action",
      $db,
      "/",
      $alert-module,
      <alert:options>{$options}</alert:options> )
  return alert:action-insert($alert-name, $action)
};