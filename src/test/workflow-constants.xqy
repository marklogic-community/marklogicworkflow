xquery version "1.0-ml";

module namespace const = "http://marklogic.com/roxy/workflow-constants";
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace mime-types = "http://marklogic.com/workflow/mime-types" at "/lib/mime-types.xqy";

(: configured at deploy time by Roxy deployer :)
declare variable $const:USER := $c:USER;
declare variable $const:PASSWORD := $c:PASSWORD;
declare variable $const:RESTHOST := $c:RESTHOST;
declare variable $const:RESTPORT := $c:RESTPORT;

(: to do - change to send json too :)
declare variable $const:json-options :=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>{$const:USER}</username>
      <password>{$const:PASSWORD}</password>
    </authentication>
    <headers>
      <content-type>{$mime-types:XML}</content-type>
      <accept>{$mime-types:JSON}</accept>
    </headers>
  </options>;

declare variable $const:xml-options :=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>{$const:USER}</username>
      <password>{$const:PASSWORD}</password>
    </authentication>
    <headers>
      <content-type>{$mime-types:XML}</content-type>
      <accept>{$mime-types:XML}</accept>
    </headers>
  </options>;

(: to do - change to send json too :)
declare variable $const:html-options :=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>{$const:USER}</username>
      <password>{$const:PASSWORD}</password>
    </authentication>
    <headers>
      <content-type>{$mime-types:XML}</content-type>
      <accept>{$mime-types:HTML}</accept>
    </headers>
  </options>;

declare variable $const:json-failure-options :=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>test-workflow-user</username>
      <password>test-workflow-user</password>
    </authentication>
    <headers>
      <content-type>{$mime-types:XML}</content-type>
      <accept>{$mime-types:JSON}</accept>
    </headers>
  </options>;

declare variable $const:xml-failure-options :=
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>test-workflow-user</username>
      <password>test-workflow-user</password>
    </authentication>
    <headers>
      <content-type>{$mime-types:XML}</content-type>
      <accept>{$mime-types:XML}</accept>
    </headers>
  </options>;

