({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.cloneAnySobjet");
        action.setParams({"recordId": recordId,
                          "objectName" : component.get("v.sObjectName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal=response.getReturnValue();
                var childRecordId=component.set("v.childRecordId",returnVal);
            /*    var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": returnVal
                });
                editRecordEvent.fire(); */
            }	
            else if (state === "ERROR"){
                var errors = response.getError();
                if(errors) {
                    component.set("v.errorMsg", errors[0].message);
                    var errorMsg = component.find('errorMsg');
                    $A.util.removeClass(errorMsg, 'slds-hide');
                    var field = component.find('field');
                    $A.util.addClass(field, 'slds-hide');
                }
                
            } 
        });
        $A.enqueueAction(action); 
        
    },
    
    handleSubmit: function (component, event, helper) {
        var childRecordId=component.get("v.childRecordId");
        var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": childRecordId,
                    "slideDevName": "detail" 
                });
               sObjectEvent.fire();
       }
    
  
})