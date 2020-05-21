({
	doInit : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
		 
		helper.getSignAgreement(component,event,helper);
		helper.getOpportunity(component,event,helper);
		// helper.getResult(component,event,helper);
	}
})