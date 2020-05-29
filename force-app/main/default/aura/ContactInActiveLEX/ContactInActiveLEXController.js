({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateContact");
        action.setParams({"recordId": recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var title = '';
            var type = '' ;
            var message = '';
            if(state === "SUCCESS") {
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