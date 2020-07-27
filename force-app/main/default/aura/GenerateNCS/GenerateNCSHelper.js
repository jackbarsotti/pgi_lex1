({
    getOpportunity : function(component, event, helper) {
        var action = component.get("c.getOpportunityData");
        action.setParams({
            oppId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: ',state);
            var title = '';
            var type = '' ;
            var message = '';
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();
                if(opp.StageName != "Closed Won"){
                    title = 'Warning!';
                    type = 'warning';
                    message = 'The Stage is not closed won.';
                    helper.showToast(component, event,title,type,message);
                }else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/apex/ist_ncs_form?opp=' + component.get('v.recordId')
                    });
                    urlEvent.fire();
                }
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
            else{
                    title = 'Warning!';
                    type = 'warning';
                    message = 'This User is not Permitted';
                helper.showToast(component, event,title,type,message);
            }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, event,title,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})