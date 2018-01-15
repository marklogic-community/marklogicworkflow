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
<case xmlns="" id="123456" update-tag="ABCD1234">
  <data>
    <!-- Arbitrary elements provided by the application. -->
  </data>
  <attachments>
    <attachment id="1" name="AccountOpeningForm" uri="/some/doc.xml" cardinality="1" /> <!-- A MarkLogic document attachment -->
    <attachment id="2" name="PDFRendering" uri="" cardinality="1" /> <!-- Named attachment, not currently linked to any system content -->
    <attachment id="3" name="CRMReference" system-type="OracleCRM" system-name="MyCRMSystem" system-id="1234567890" cardinality="1" /> <!-- external reference -->
    <attachment id="4" name="RelatedContent" uri="/my/saved/search.xml" cardinality="*" /> <!-- MarkLogic Saved Search (aka Smart Folder) -->
  </attachments>
  <audit-trail>
    <by>afowler</by><when>20170118T130413Z</when>
    <category>Lifecycle|Administrative</category><status>Closed|Open (at point After update)</status>
    <description>Some textual description</description><detail><!-- Contains the dataUpdates and attachmentUpdates elements in their entirety --></detail>
  </audit-trail>
  <phases>
    <phase id="phaseUid1">      
      <metadata>
        <name>Initial</name>
        <public-name></public-name>        
      </metadata>      
      <activities>
        <activity id="uid1">
          <metadata>
            <name>ContactCustomer</name>
            <public-name></public-name> 
          </metadata>          
          <status>NotActive|Open|Completed|Skipped</status> <!-- See audit-trail for relevant completion information -->
          <description>Please phone the customer to let them know we are handling their case, and ask for any missing info</description>
          <notes>Any notes here to record for this activity, outcomes, or information to the person completing it.</notes>
          <results>
            <result type="attachment">                        
                <values>
                    <value>attachmentId1</value>
                </values>                                                           
            </result>                
            <result type="singleValue" uri="/reference/type-list.xml">
                <values>
                    <value>
                    </value>
                </values>                                                           
            </result>            
            <result type="multipleValue" uri="/reference/type-list.xml">                                                           
                <values>
                    <value>
                    </value>
                </values>                                                           
            </result>            
          </results>
        </activity>
      </activities>
    </phase>
  </phases>
  <metrics>
    <!-- Currently blank, but reserved for future use (just like in MarkLogic Workflow) -->
  </metrics>
  <status>NotActive|Open|Closed|Provisional|Cancelled</status>
  <active-phase>phaseUid1</active-phase>
  <locked>true|false</locked>
  <locked-by>afowler</locked-by>
  <case-template-name>Account Opening Request</case-template-name>
  <parent>567890</parent>
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
