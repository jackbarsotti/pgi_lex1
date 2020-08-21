({
	// Your renderer method overrides go here

	// It will call onLoad of Component
    render: function(cmp, helper) {
        var ret = cmp.superRender(); 
        helper.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));
        return ret; 
    },
})