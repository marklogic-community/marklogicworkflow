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
      <permissions>
        <new-permissions>true</new-permissions>
      </permissions>
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
      <permissions>
        <new-permissions>false</new-permissions>
      </permissions>
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
    <action name="patch activity">
      <activity>
        <activity-exists>true</activity-exists>
      </activity>
      <data>
        <data-expected>true</data-expected>
        <patches-expected>true</patches-expected>
      </data>
    </action>
  </actions>;

