# MarkLogic Case REST API

## Phase 1

- **GET case**
  - Get a case instance (optional - summary only)
  - whole case XML as it is.
  - filter out audit info, only provide last-updated and created-date.
- **POST case**
  - create a new case instance, case instance XML can be sent from the client
  - generate UID for case.
  - permissions - discussion?
  - maintain audit-trail
- **PUT case**
  - Update an existing case - C (including update tag support)
  - TODO update tests with update-tag support (and add a test for old tag)
- **GET caseactivity**
  - Return a single case activity  
- **POST caseactivity**
  - Add a ad-hoc case activity to a given case, caseId, phaseId
- **PUT caseactivity**
  - Update the elements within a activity, adds or updates elements that have been provided, never delete any element. *For delete use PATCH.*
- **PATCH caseactivity**
  - patch - insert, replace, delete elements in an activity **(note this can only be accessed by PUT using the parameter rs:patch=true or X-HTTP-Method-Override: PATCH)**
```
$ curl --anyauth --user user:password -X PUT -d @./patch.xml \
    -i -H "Content-type: application/xml" \
    -H "Accept: application/xml" \
    -H "X-HTTP-Method-Override: PATCH" \
    http://localhost:8040/v1/resources/caseactivity?rs:activityId=activity1
```

## Phase 2

- **POST case**
  - Create a new case instance, based on template ID
    - create case based on the template ID
    - identity of the user
    - metadata
    - filter criteria based on which casetemplate is filtered and certain activities are included or not.
- **PUT case**
  - no change needed from Phase 1
- **GET case**
  - filter the fields based on XPath
- **DELETE case**
  - Close a case (Does NOT actually delete the record, it is a logical delete)
- **POST casetemplate**
  - Create a new template, use DLS versioning functions, think how case refers to the caseTemplateId?
- **PUT casetemplate**
  - update a template, use DLS versioning functions
    - Update the elements within the template, adds or updates elements that have been provided, never delete any element.
- **PATCH casetemplate**
  - For delete use PATCH.
    - add a phase
    - add a activity        
- **DELETE casetemplate**
  - Logical delete of a case template
- **GET casetemplate**
  - Retrieve a case template

### Security (Authorisation/Entitlement)
- All Case API's would accept <sec:permissions> which would have role-name and capability. If permissions are supplied then no default permissions are applied, otherwise
default permissions are applied  
- there will be default roles like "case-admin", "case-reader", "case-writer" etc which will be used to authroize wether the API(s) can be invoked or not.

### PROCESS
- store graph in triples DB, but return RDF XML as part of GET case API.
- TODO - Discuss how graph is created as a whole or API's to maintain graph ?
- how process is validated ? and business rules are enforced ?
- how initial planning and re-planning work ?

- **POST casesearch**
  - snippet - case metadata, title, last-modified, 4-5 properties about the case.(including historical)

## Phase 3

- **POST casetemplatesearch**

### PROCESS
- apis to do validation, reasoning

## Phase 4

### Sub cases

OOTB TDE/row configuration

- **POST /configuration/<type>**
- **GET /configuration/<type>**
