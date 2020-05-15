({
    doInit : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Financial_Request__c",
                "defaultFieldValues":{
                    "Related_FinReq__c" : component.get("v.recordId"),
                    "RecordTypeId" : '0121B0000018GkWQAU'
                }
            });
           createRecordEvent.fire();
    }
})