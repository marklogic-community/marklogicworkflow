xquery version "1.0-ml";
import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace lnk = "http://marklogic.com/cpf/links" at "/MarkLogic/cpf/links.xqy";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;

try {
   lnk:propagate-rename( $cpf:document-uri )
   ,
   cpf:success( $cpf:document-uri, $cpf:transition, () )
}
catch ($e) {
   cpf:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
