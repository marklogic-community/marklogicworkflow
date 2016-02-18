xquery version "1.0-ml";

module namespace m = "http://marklogic.com/workflow/html"; (: Shared namespace :)

declare default namespace "http://HTMLNAMESPACE";

(:
 : HATEOAS module to allow viewing in HTML of MLWF available actions
 :)

declare function m:processmodel-get($readResponse as element()) as document() {
  m:page(
    if (fn:local-name($readResponse) = "list") then
      <div id='processmodel-list'><h2>Available Process Models</h2><table style='border: 1px solid black;'>
        <tr><th>Name</th><th>Description</th><th>publishedId</th><th>Major</th><th>Minor</th><th>Actions</th></tr>
      {
        for $summary in $readResponse/wf:model-summary
        return
          <tr>
            <td>{$summary/name/text()}</td><td>{$summary/description/text()}</td>
            <td>{$summary/process-name/text()}</td><td>{xs:string($summary/major)}</td>
            <td>{xs:string($summary/minor)}</td>
            <td>{
              if ("true" = $summary/enabled) then
                <form id='processmodel-list-{xs:string($summary/process-name)}-create' method='PUT' target='{m:link("process")}'>
                  <button onclick='javascript: this.parent.submit();'>Launch</button>
                </form>
              else ()
              ,
              " ["
              ,
              <a href='{m:link("processmodel?rs:publishedId=" || xs:string($summary/process-name))}'>Download</a>
              ,
              "] "
            }</td>
          </tr>
      }
      </table>
      </div>
      <div id='processmodel-new'><h2>Upload a new process model</h2>
        <form id='processmodel-new-form' name='processmodel-new-form' method='PUT' enctype='application/x-www-form-urlencoded'
              target='{m:link("processmodel")}'>
                TODO show a new process model upload form here - name, major, minor, enable
            <button onclick='javascript: this.parent.submit();'>Upload</button>
        </form>
      </div>
    else
      $readResponse
  )
};
