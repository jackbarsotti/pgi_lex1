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
			}else{
				console.log('Error');
			}
		})
		$A.enqueueAction(action);
	}
})