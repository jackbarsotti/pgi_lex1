({
    doInit : function(component, event, helper) { 
        var sObjectName = component.get("v.sObjectName");
        console.log('sObjectName: ',sObjectName);
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateRecord");
        action.setParams({"recordId": component.get("v.recordId"),
                          "objectName" : component.get("v.sObjectName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var title = '';
            var type = '' ;
            var message = '';
            if(state === "SUCCESS") {
                title = 'Success';
                type = 'success';
                message = 'Record is Assigned Successfully';
                helper.showToast(component, event,title,type,message);
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToast(component, event,title,type,message);
                    }
                } else {
                    title = 'Error';
                    type = 'error';
                    message = 'Unknown error';
                    helper.showToast(component, event,title,type,message);
                }
            }
        });
        $A.enqueueAction(action); 
    }
})