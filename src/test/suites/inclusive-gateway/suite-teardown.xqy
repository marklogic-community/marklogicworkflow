xquery version "1.0-ml";
(
  xdmp:directory-delete("/"),
  xdmp:collection-delete("http://marklogic.com/cpf/pipelines")
)
