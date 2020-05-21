({
    getAccounts : function(component, event, helper) {
        var action = component.get("c.getAccountRecords");
        action.setParams({
            accId : component.get('v.recordId')
        });
        action.setCallback(this, function(responce){
            var state = responce.getState();
            if(state === 'SUCCESS'){
                var result = responce.getReturnValue();
                console.log('>> result >>',result);
                if(result.NetSuite_Pull__c === 'true' || result.NetSuite_Push__c === 'true'){
                    console.log('>> values are true');
                }else{
                    console.log('>> values are empty or false');
                }
            }
        });
        $A.enqueueAction(action);
    }
})