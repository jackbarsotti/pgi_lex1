({
	doInit : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        helper.getCustomSetting(component,event,helper);
	}
})