({
	escalateEmailCase : function(component, event, helper) {
		var action = component.get('c.createEscalationRecord');
		action.setParams({
			recordId : component.get('V.recordId'),
			escalationType : component.get('V.selectedType'),
			escalationRecordType : component.get('V.selectedRecordType'),
		})
		action.setCallback(this, function(response){
			var state = response.getState();
            console.log('state: ',state);
            if (state === "SUCCESS") {
				console.log('response=>',response.getReturnValue());
				var navEvt = $A.get("e.force:navigateToSObject");
				helper.showToast(component, event, 'This Email is escalated', 'success', 'Successful');
				navEvt.setParams({
				"recordId": response.getReturnValue()
				});
				navEvt.fire();
			}else{
				console.log('Error');
			}
		})
		$A.enqueueAction(action);
	},
	isEscalated :function(component, event, helper) {
		var action = component.get('c.getIsEscalated');
		action.setParams({
			recordId : component.get('V.recordId')
		})
		action.setCallback(this, function(response){
			var state = response.getState();
            console.log('state: ',state);
            if (state === "SUCCESS") {
				component.set('v.isEscalated',response.getReturnValue());
				if(response.getReturnValue() == true){
					helper.showToast(component, event, 'This Email has already been escalated, please view the Parent Case or related FinReq for further actions', 'info', 'Already Escalated');
				}
			}else{
				console.log('Error');
			}
		})
		$A.enqueueAction(action);
	},
	showToast : function(component, event, message, type, title) {
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