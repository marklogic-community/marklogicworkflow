xquery version "1.0-ml";

module namespace m = "http://marklogic.com/workflow/html"; (: Shared namespace :)

declare default namespace "http://HTMLNAMESPACE";

(:
 : Provides the central base layout to the page. Designed deliberately to be a simple interface, not a complete webapp.
 :)
declare function m:page($main as element()) as document() {
  document {
    <html>
      <head>
        <title>MarkLogic Workflow</title>
      </head>
      <body>
        <div id='banner'><h2>MarkLogic Workflow</h2></div>
        <div id='navigation'>
          <a href='{$m:link("processmodel")}'>List process models</a> |
          <a href='{$m:link("processengine")}'>List running process' status</a> |
          <a href='{$m:link("processinbox")}'>Show my work inbox</a> |
          <a href='{$m:link("processqueue")}'>List available work queues</a> |
          <a href='{$m:link("processroelinbox")}'>List my role assigned work items</a> |
          <a href='{$m:link("processsubscriptions")}'>List workflow subscriptions</a> |
          <a href='{$m:link("processassets")}'>List workflow assets (should be via list models?)</a>
        </div>
        <div id='content'>{$main}</div>
        <div id='footer'>MarkLogic Workflow and this application are copyright MarkLogic Corporation 2015. All rights reserved.</div>
      </body>
    </html>
  }
};

(:
 : Constructs a URL using querystring parameters. Assumes the initial URL does not contain a ? character already.
 :)
declare function m:link($after as xs:string,$params as map:map?) as xs:string {
  "/v1/resources/" || $after || (
    for $key at $idx in map:keys($params)
    return
    (
      (if (1 = $idx) then "?" else "&") || $key || "=" || xs:string(map:get($params,$key))
    )
  )
};
