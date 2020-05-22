({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.cloneAnySobjet");
        action.setParams({"recordId": component.get("v.recordId"),
                          "objectName" : component.get("v.sObjectName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal=response.getReturnValue();
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": returnVal
                });
                editRecordEvent.fire(); 
                
                $A.get("e.force:closeQuickAction").fire(); 
              /*  var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                sObjectEvent.fire(); */
                 
            }
             	
            else if (state === "ERROR"){
                var errors = response.getError();
                if(errors) {
                    cmp.set("v.errorMsg", errors[0].message);
                    var errorMsg = cmp.find('errorMsg');
                    $A.util.removeClass(errorMsg, 'slds-hide');
                    var field = cmp.find('field');
                    $A.util.addClass(field, 'slds-hide');
                }
                
            }
        });
        $A.enqueueAction(action); 
        
    }
})