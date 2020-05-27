({
    doInit : function(component, event, helper) { 
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateRecord");
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : 'Success',
            "message": 'The user has been updated'
        });
        toastEvent.fire();
                
                
            }
        });
        $A.enqueueAction(action); 
    }
})