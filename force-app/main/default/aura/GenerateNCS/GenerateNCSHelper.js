({
    getOpportunity : function(component, event, helper) {
        var action = component.get("c.getOpportunityData");
        action.setParams({
            oppId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: ',state);
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();
                if(opp.StageName != "Closed Won"){
                    helper.showToast(component,event,"The Stage is not closed won.");
                }else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/apex/ist_ncs_form?opp=' + component.get('v.recordId')
                    });
                    urlEvent.fire();
                }
            }else{
                helper.showToast(component,event,"This User is not Permitted");
            }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Warning!",
            "type" : 'warning',
            "message": message
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})