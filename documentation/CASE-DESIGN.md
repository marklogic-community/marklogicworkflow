# MarkLogic Case Design


## Internal fields

## Application fields

## Pre-defined or ad-hoc activities and phases

How MarkLogic Case supports both mechanisms.

## Integration with Workflow

Find case (E.g. by ID/search)
Create case
Attach case to process
Detach case from process
Update case (with reassign) (Is Complete Activity the same or separate?)
Close case
Attach to case
Detach from case

Primary Case (for current process instance)

## Sample case document

```xml
<case id="1" xmlns="http://marklogic.com/workflow/case" template-id="ctemplate1">
	<data>
		<latest-version>0</latest-version>
		<publication-date>12-04-2016</publication-date>
	</data>
	<active-phase>phaseUid1</active-phase>
	<phases>
		<phase id="phase1" template-id="ptemplate1">
			<data>
				<name>Intial</name>
				<public-name>Updated Case Example</public-name>
			</data>
			<activities>
				<activity id="activity1" template-id="atemplate1">
					<data>
						<name>Contact Customer</name>
						<public-name>Contact Customer</public-name>
						<planned-start-date>11-05-2017</planned-start-date>
						<planned-end-date>10-06-2017</planned-end-date>
						<actual-start-date>15-05-2017</actual-start-date>
						<actual-end-date>14-06-2017</actual-end-date>
					</data>
					<status>NotActive</status>
					<description>string</description>
					<notes>string</notes>
					<results>
						<result id="result1">
							<type>attachment</type>
							<values>
								<value>string</value>
							</values>
						</result>
					</results>
				</activity>
			</activities>
			<graph>
				<RDF xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				</RDF>
			</graph>
		</phase>
	</phases>
	<attachments>
		<attachment>string</attachment>
	</attachments>
	<status>NotActive</status>
	<parent>567892</parent>
</case>
```

status - could be reference data.


1. The id is an auto generated ID using a random number, a hyphen, and the current date time
1. The update-tag is the same format as the ID, but allows Case Management to reject a second update to the same case state.
   I.e. if two people opened the case at the same time, the first one to update or close the case 'wins'.
1. The data element holds application specific data. This is left entirely to the case application and template to provide.
1. Attachments are any internal (MarkLogic) or external (other system) 'attachments'. These can be actual documents in MarkLogic,
   or (in future) saved searches (like Smart folders on a Mac or Smart Playlists in iTunes)
1. Audit trail provides for who did what, and when. Currently this is a set of XML elements. In future this may also include PROV-O triples.
1. Metrics holds how long a case has been at a particular stage, and when this was. This allows performance information to be held.
   Currently this is not used, but is reserved for future use.
1. The status is a simple Open or Closed status. This allows effective searching of current live cases.
1. Locked shows whether this case is locked for edit. Note it may be possible for a single user to have multiple sessions with the client app, so
   we cannot assume the locked and locked-by elements are sufficient on their own, hence the addition of update-tag.
1. case-template-name will show the template used to create this case. If a template is not used, this is an arbitrary case class identifier string.
   Currently this is not used, but is reserved for future use.
1. parent holds the case ID of any parent case. Currently this is not used, but is reserved for future use.
1. A State is the current location of the Case in its lifecycle (if any). A Phase consists of one or more states.
1. A Milestone is a fixed point in time during a case's lifecycle. A milestone can be achieved during, after, or between states.

## Example PATCH XML

```
<rapi:patch xmlns:rapi="http://marklogic.com/rest-api" xmlns:c="http://marklogic.com/workflow/case">
  <rapi:insert context="/c:activity" position="last-child">
    <c:inserted/>
  </rapi:insert>
  <rapi:replace select="/c:activity/c:data/c:latest-version">
    <c:latest-version>1</c:latest-version>
  </rapi:replace>
  <rapi:delete select="//c:child/c:grandchild"/>
</rapi:patch>
```
