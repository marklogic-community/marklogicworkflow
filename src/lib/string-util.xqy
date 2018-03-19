module namespace string-util = "http://marklogic.com/workflow/string-util";

declare function capitalize($string as xs:string){
  fn:upper-case(fn:substring($string,1,1))||fn:lower-case(fn:substring($string,2,fn:string-length($string)))
};

declare function dash-format-string($string as xs:string){
  let $strings := (fn:tokenize($string,"-") ! capitalize(.))
  return
  fn:string-join($strings," ")
};
