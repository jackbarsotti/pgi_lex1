({
	showToast : function(component, event,title,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
        if(message.includes("Success")){
             var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        }
       
    }
})