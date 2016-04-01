xquery version "1.0-ml";

module namespace s="http://marklogic.com/sectest";

import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";

declare private variable $privDesigner as xs:string := "http://marklogic.com/workflow/privileges/designer"; (: Process MODEL designers :)

declare function s:callme() as xs:string {
  let $_secure := xdmp:security-assert($privDesigner, "execute")
  return "If you see this, all is well, my friend"
};

declare function s:cpfme() {
  p:insert(<somexml></somexml>)
};
