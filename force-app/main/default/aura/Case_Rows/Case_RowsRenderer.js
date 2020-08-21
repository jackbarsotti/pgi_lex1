({
	// Your renderer method overrides go here
	render: function(cmp, helper) {
        var ret = cmp.superRender(); 
        	helper.getRelatedFields(cmp, cmp.get("v.ote_rule.Object_Name__c"));
        return ret; 
    },
})