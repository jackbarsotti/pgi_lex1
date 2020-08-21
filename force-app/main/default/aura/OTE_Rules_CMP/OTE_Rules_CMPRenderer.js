({
	render: function(cmp, helper) {
        var ret = cmp.superRender(); 
        helper.getMRKeyPrefix(cmp);
        // helper.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));
        return ret; 
    },
})