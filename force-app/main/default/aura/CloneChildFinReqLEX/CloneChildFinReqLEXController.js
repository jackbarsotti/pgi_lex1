({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.cloneAnySobjet");
        action.setParams({"recordId": recordId,
                          "objectName" : component.get("v.sObjectName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.spinner",false);
                var returnVal=response.getReturnValue();
                var createCloneRec = $A.get("e.force:createRecord");
                createCloneRec.setParams({
                    "entityApiName": "Financial_Request__c",
                    "defaultFieldValues": returnVal
                });
                createCloneRec.fire();
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
        
    }
    
})