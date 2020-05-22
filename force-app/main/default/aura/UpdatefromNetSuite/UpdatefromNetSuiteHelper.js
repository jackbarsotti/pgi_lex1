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
                component.set("v.accountRecordList",result);
                console.log('>> result >>',result)
                if(result.NetSuite_Pull__c === true || result.NetSuite_Push__c === true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : 'warning',
                        "message": "Sync already in progress."
                    });
                    toastEvent.fire();
                }
                else{
                    helper.updateAccountSync(component, event, helper);
                    helper.openPopUp(component, event, helper);
                    // helper.checkSyncStatus(component, event, helper);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.checkSyncStatus(component, event, helper)
                        }), 5000
                    );
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateAccountSync : function(component, event, helper){
        console.log('>> update account sync >>');
        var action = component.get("c.updateAccountRecord");
        action.setParams({
            accId : component.get('v.recordId')
        });
        action.setCallback(this, function(responce){
            var state = responce.getState();
            console.log('>> state fro update >>',state);
        });
        console.log('>> record values are updated >>');
        $A.enqueueAction(action);
    },
    openPopUp : function(component, event, helper){
        var accountId = component.get('v.recordId');
        console.log('>> inside show popup >>');
        var top = screen.height - (screen.height * .5) - 100;
        var left = screen.width - (screen.width * .5) - 187;
        var params = 'dependent = yes,resizable=false,scrollbars=false,toolbar=false,menubar=false,location=false,status=true,directories=false,width=375,height=160,top=';
        params += top.toString();
        params += ',left=' + left.toString() + '\'';
        window.open('/apex/account_status?whence='+accountId, 'NetSuite_Synchronization', params);
        
    },
    checkSyncStatus : function(component, event, helper){
        var retries = 0;
        var maxRetries = 20;
        
        var action = component.get("c.getAccountRecords");
        action.setParams({
            accId : component.get('v.recordId')
        });
        action.setCallback(this, function(responce){
            var state = responce.getState();
            console.log('>> state >>',state);
            if(state === 'SUCCESS'){
                var result = responce.getReturnValue();
                if (res.NetSuite_Pull__c === false){
                    window.location.href = window.location.href;
                    console.log('>> window.location.href >>',window.location.href);
                }
                else if(retries < maxRetries){
                    console.log('>> else if in checkSyncStatus >>');
                    retries++;
                    //window.setTimeout(that.checkSyncStatus, 5000);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.checkSyncStatus(component, event, helper)
                        }), 5000
                    );
                    console.log('>> after time out >>');
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : 'warning',
                    "message": "An error has occurred, please contact your Celigo representative: "+state
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})