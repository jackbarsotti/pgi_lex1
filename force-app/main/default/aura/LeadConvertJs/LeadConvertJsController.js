({
	doInit : function(component, event, helper) {
		var action = component.get("c.getStatus");
        action.setParams({
            recordId : component.get('v.recordId')
        });
         action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: ',state);
            if (state === "SUCCESS") {
                var status = response.getReturnValue();
                if(status == 'Qualifying'){
                    var id = component.get('v.recordId');
                    window.location = '/lead/leadconvert.jsp?retURL=%2F'+id+'&id='+id;
                }
                else{
                     helper.showToast(component,event,"In order to Convert, your Lead Status must be set to Qualifying");
                }
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
    }
})