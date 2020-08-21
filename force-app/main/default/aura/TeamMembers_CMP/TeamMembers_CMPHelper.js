({
	getMemberRoles: function(cmp, event) {
        
        var action = cmp.get("c.getRoleValues");
        action.setParams({
            "objName" : 'Team_Member__c'
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                let fields = res.getReturnValue();
                // fields.sort((a, b) => (a.fieldLabel > b.fieldLabel) ? 1 : (a.fieldLabel === b.fieldLabel) ? ((a.fieldApiName > b.fieldApiName) ? 1 : -1) : -1 )
                cmp.set('v.Roles',fields);
                // console.log('relatedFields>>>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.Roles"))));
            }
            return ;
        });
        $A.enqueueAction(action);

    },
    
})