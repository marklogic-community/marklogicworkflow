xquery version "1.0-ml";

declare module namespace m="http://marklogic.com/scxmltocpf";

declare namespace sc="http://www.w3.org/2005/07/scxml";

(:
 : See http://www.w3.org/TR/scxml/
 :)

declare function m:scxml-to-cpf($doc as element(sc:scxml)) as xs:string {
  (: Convert the SCXML process model to a CPF pipeline :)
  let $initial :=
    if (fn:not(fn:empty($doc/@initial))) then
      $doc/sc:state[./@id = $doc/@initial]
    else
      $doc/sc:state[1]

  (: create entry CPF action :)
  (: Link to initial state action :)

};
