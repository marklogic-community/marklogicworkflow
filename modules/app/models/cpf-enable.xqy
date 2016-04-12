xquery version "1.0-ml";

declare namespace my="http://marklogic.com/alerts";

import module namespace la = "http://marklogic.com/alerts/alerting" at "/app/models/lib-alerting.xqy";

declare variable $my:alert-name as xs:string external;
declare variable $my:cpf-domain as xs:string external;

la:cpf-enable($my:alert-name,$my:cpf-domain)