xquery version "1.0-ml";

module namespace const = "http://marklogic.com/casemanagement/case-constants";

declare variable $const:case-dir := "/casemanagement/cases/";
declare variable $const:case-collection := "http://marklogic.com/casemanagement/cases";
declare variable $const:case-permissions := (
  xdmp:permission("case-internal",("read","update")),
  xdmp:permission("case-administrator",("read","update"))
);
declare variable $const:validation :=
  <actions xmlns="http://marklogic.com/workflow/case">
    <action name="new case">
      <case>
        <case-exists>false</case-exists>
      </case>
      <data>
        <data-expected>true</data-expected>
      </data>
    </action>
    <action name="get case">
      <case>
        <case-exists>true</case-exists>
      </case>
    </action>
    <action name="update case">
      <case>
        <case-exists>true</case-exists>
      </case>
      <data>
        <data-expected>true</data-expected>
      </data>
    </action>
    <action name="new activity">
      <case>
        <case-exists>true</case-exists>
      </case>
      <activity>
        <activity-exists>false</activity-exists>
      </activity>
      <data>
        <data-expected>true</data-expected>
      </data>
    </action>
    <action name="get activity">
      <activity>
        <activity-exists>true</activity-exists>
      </activity>
    </action>
    <action name="update activity">
      <activity>
        <activity-exists>true</activity-exists>
      </activity>
      <data>
        <data-expected>true</data-expected>
      </data>
    </action>
  </actions>;
(:
<actions xmlns="http://marklogic.com/casemanagement">
  <action name="new case">
    <case-exists>false</case-exists>
    <data-expected>true</data-expected>
  </action>
  <action name="get case">
    <case-exists>true</case-exists>
  </action>
  <action name="update case">
    <case-exists>true</case-exists>
    <data-expected>true</data-expected>
  </action>
  <action name="new activity">
    <case-exists>true</case-exists>
    <activity-exists>false</activity-exists>
    <data-expected>true</data-expected>
  </action>
  <action name="get activity">
    <case-exists>true</case-exists>
    <activity-exists>true</activity-exists>
  </action>
  <action name="update activity">
    <case-exists>true</case-exists>
    <activity-exists>true</activity-exists>
    <data-expected>true</data-expected>
  </action>
</actions>;
:)

