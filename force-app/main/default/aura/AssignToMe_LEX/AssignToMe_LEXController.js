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
            if(state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action); 
    }
})