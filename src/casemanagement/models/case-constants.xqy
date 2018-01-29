xquery version "1.0-ml";

module namespace const = "http://marklogic.com/casemanagement/case-constants";

(: configured at deploy time by Roxy deployer :)
declare variable $const:case-dir := "/casemanagement/cases/";
declare variable $const:case-collection := "http://marklogic.com/casemanagement/cases";
declare variable $const:case-permissions := (
  xdmp:permission("case-internal",("read","update")),
  xdmp:permission("case-administrator",("read","update"))
);



