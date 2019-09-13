module namespace wfc = "http://marklogic.com/workflow/constants";

(: REST Status constants :)
declare variable $SERVICE-SUCCESS-RESPONSE := "SUCCESS";
declare variable $SERVICE-FAILURE-RESPONSE := "FAILURE";

(: Namespaces :)
declare variable $WORKFLOW-NAMESPACE := "http://marklogic.com/workflow";

(: Collections :)
declare variable $MODEL-COLLECTION := $WORKFLOW-NAMESPACE||"/model";

(: Directories :)
declare variable $WORKFLOW-DIRECTORY := "/workflow/";
declare variable $MODELS-DIRECTORY := $WORKFLOW-DIRECTORY||"models/";