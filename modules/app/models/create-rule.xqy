xquery version "1.0-ml";

declare namespace my="http://marklogic.com/alerts";

import module namespace la = "http://marklogic.com/alerts/alerting" at "/app/models/lib-alerting.xqy";

declare variable $my:alert-name as xs:string external;
declare variable $my:query as cts:query external;
declare variable $my:options as cts:query external;

la:create-rule($my:alert-name,$my:query,$my:options)