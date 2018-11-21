xquery version "1.0-ml";

let $_clean-data := (
  xdmp:directory-delete("/"),
  xdmp:collection-delete("http://marklogic.com/cpf/pipelines")
)
return ()
