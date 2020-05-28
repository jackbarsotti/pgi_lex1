({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.cloneAnySobjet");
        action.setParams({"recordId": recordId,
                          "objectName" : component.get("v.sObjectName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var title = '';
            var type = '' ;
            var message = '';
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
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToast(component, event,title,type,message);
                        $A.get("e.force:closeQuickAction");
                    }
                }
                
            } 
        });
        $A.enqueueAction(action); 
        
    }
    
})