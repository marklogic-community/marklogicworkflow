xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-assets";

declare namespace wf="http://marklogic.com/workflow";
import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : TODO refactor away the eval strings
 :)


declare function m:setProcessAsset($assetname as xs:string,$asset as node(), $processName as xs:string,$major as xs:string?,$minor as xs:string?) as xs:string {
  let $_secure := xdmp:security-assert($wfdefs:privManager, "execute")

  return xdmp:eval(
    'xquery version "1.0-ml";declare namespace wf="http://marklogic.com/workflow";' ||
    'declare variable $wf:processName as xs:string external;' ||
    'declare variable $wf:major as xs:string external;' ||
    'declare variable $wf:minor as xs:string external;' ||
    'declare variable $wf:assetname as xs:string external;' ||
    'declare variable $wf:asset as node() external;' ||
    'let $uri := "/workflowengine/assets/" || fn:string-join(($wf:processName,$wf:major,$wf:minor),"/") || "/" || $wf:assetname ' ||
    'return (xdmp:document-insert($uri,$asset),$uri)'
    , (: TODO security permissions and properties for easy finding :)

      (xs:QName("wf:processName"),$processName,xs:QName("wf:assetname"),$assetname,xs:QName("wf:major"),$major,
       xs:QName("wf:minor"),$minor,xs:QName("wf:asset"),$asset),
      <options xmlns="xdmp:eval">
        <database>{xdmp:modules-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )  (: MUST be executed in the modules DB - where the assets live :)
};


declare function m:deleteProcessAsset($assetname as xs:string,$processName as xs:string,$major as xs:string?,$minor as xs:string?) as xs:string {
  let $_secure := xdmp:security-assert($wfdefs:privManager, "execute")

  return xdmp:eval(
    'xquery version "1.0-ml";declare namespace wf="http://marklogic.com/workflow";' ||
    'declare variable $wf:processName as xs:string external;' ||
    'declare variable $wf:major as xs:string external;' ||
    'declare variable $wf:minor as xs:string external;' ||
    'declare variable $wf:assetname as xs:string external;' ||
    'let $uri := "/workflowengine/assets/" || fn:string-join(($wf:processName,$wf:major,$wf:minor),"/") || "/" || $wf:assetname ' ||
    'return (xdmp:document-delete($uri),$uri)'
    , (: TODO security test :)

      (xs:QName("wf:processName"),$processName,xs:QName("wf:assetname"),$assetname,xs:QName("wf:major"),$major,
       xs:QName("wf:minor"),$minor),
      <options xmlns="xdmp:eval">
        <database>{xdmp:modules-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )  (: MUST be executed in the modules DB - where the assets live :)
};

declare function m:getProcessAssets($assetname as xs:string?,$processName as xs:string,$major as xs:string?,$minor as xs:string?) as node()* {
  let $_secure := xdmp:security-assert(($wfdefs:privManager,$wfdefs:privRuntime), "execute") (: TODO validate this :)

  return xdmp:eval(
    'xquery version "1.0-ml";declare namespace wf="http://marklogic.com/workflow";' ||
    'declare variable $wf:processName as xs:string external;' ||
    'declare variable $wf:major as xs:string external;' ||
    'declare variable $wf:minor as xs:string external;' ||
    'declare variable $wf:assetname as xs:string external;' ||
    ' (fn:doc("/workflowengine/assets/" || $wf:processName || "/" || $wf:major || "/" || $wf:minor || "/" || $wf:assetname ),' ||
    '  fn:doc("/workflowengine/assets/" || $wf:processName || "/" || $wf:major || "/" || "/" || $wf:assetname ),' ||
    '  fn:doc("/workflowengine/assets/" || $wf:processName || "/" || $wf:assetname )' ||
    ')[1]'
    (: TODO support blank asset name by listing all processes within processName's URI folder :)
    ,
      (xs:QName("wf:processName"),$processName,xs:QName("wf:assetname"),$assetname,xs:QName("wf:major"),$major,xs:QName("wf:minor"),$minor),
      <options xmlns="xdmp:eval">
        <database>{xdmp:modules-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )  (: MUST be executed in the modules DB - where the assets live :)
};






declare function m:getProcessInstanceAsset($processUri as xs:string,$assetname as xs:string) as node()? {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute") (: Not the runtime permission needed also for this one! :)

  let $process := fn:doc($processUri)/wf:process
  return
    m:getProcessAssets($assetname,xs:string($process/@name),xs:string($process/@major),xs:string($process/@minor))[1]
};
