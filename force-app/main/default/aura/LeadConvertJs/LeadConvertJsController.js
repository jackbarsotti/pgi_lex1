({
	doInit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
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
                      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Warning!",
            "type" : 'warning',
            "message": 'In order to Convert, your Lead Status must be set to Qualifying'
        });
        toastEvent.fire();
                }
            }
        })
        $A.enqueueAction(action);
	}
})