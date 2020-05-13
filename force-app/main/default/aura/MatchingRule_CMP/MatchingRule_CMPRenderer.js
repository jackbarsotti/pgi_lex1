({
    // Your renderer method overrides go here
    // rerender : function(cmp, helper) {
    //     console.log('Afterrerender'); 

    //     var ret = cmp.superRerender(); 
    //     helper.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));
    //     return ret; 
    // },
    
    // It will call onLoad of Component
    render: function(cmp, helper) {
        var ret = cmp.superRender(); 
        helper.getMRKeyPrefix(cmp);
        // helper.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));
        return ret; 
    },

    
})