({
    // fetchDetails : function(component, event, helper) {
    //     var action = component.get("c.fetchDetails");
    //     action.setCallback(this, function(response) {
    //         if (response.getState() == "SUCCESS") {
    //             var arrayOfMapKeys = [];
    //             var StoreResponse = JSON.parse(JSON.stringify(response.getReturnValue().sprintMap));
    //             console.log('The ac',StoreResponse);
    //             component.set('v.agileSprint',StoreResponse);
    //              component.set('v.agiletoCaseList',JSON.parse(JSON.stringify(response.getReturnValue().sprinttoCaseMap)));
    //             //   for (var singlekey in StoreResponse) {
    //             //   	 arrayOfMapKeys.push(singlekey);
    //             //   }
    //             component.set('v.groupToCaseMap',JSON.parse(JSON.stringify(response.getReturnValue().grouptoagileId)));
    //             console.log('GC is',component.get('v.groupToCaseMap'));
    //             component.set('v.lstKey', JSON.parse(JSON.stringify(response.getReturnValue().agileSprintId)));
    //             console.log('The sprintMap123Key',component.get('v.lstKey'));
    //             console.log('The sprintMap',component.get('v.agileSprint'));
    //             console.log('The sprinttoCaseMap',component.get('v.agiletoCaseList'));
    //             component.set('v.keyLength',component.get('v.lstKey').length);
    //         }
    //     })
    //     $A.enqueueAction(action);
    // },
    // getCaseStatus : function(component, event, helper) {
    //     var action = component.get("c.getPickListValuesIntoList");
    //     action.setParams({
    //         "ObjectApi_name" : 'Case',
    //         "Field_name" : 'AgileStatus__c'
    //     });
    //     action.setCallback(this, function(response) {
    //         console.log('Testing123');
    //         if (response.getState() == "SUCCESS") {
    //             console.log('Testing');
    //             var allValues = response.getReturnValue();
    //             component.set('v.caseStatusPicklist', allValues);
    //             console.log('Testing123',component.get('v.caseStatusPicklist'));
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    // getGroupMember : function(component, event, helper) {
    //     var action = component.get("c.getPickListValuesIntoList");
    //     console.log('Testing13');
    //     action.setParams({
    //         "ObjectApi_name" : 'AgileSprint__c',
    //         "Field_name" : 'AssociatedGroup__c'
    //     });
    //     action.setCallback(this, function(response) {
    //         console.log('Testing13',response.getState());  
    //         if (response.getState() == "SUCCESS") {
    //             console.log('Testing');
    //             var allValues = response.getReturnValue();
    //             component.set('v.picklistOptions', allValues);
    //             console.log('Testing',component.get('v.picklistOptions'));
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    // fetchBacklogcase: function(component, event, helper) {
    //     console.log('test');
    //     var action = component.get("c.fetchBacklogCase"); 
    //     action.setCallback(this, function(response) {
    //         if (response.getState() == "SUCCESS") {
    //             component.set('v.backlogCases',JSON.parse(JSON.stringify(response.getReturnValue())));
    //             console.log('The Response is',component.get('v.backlogCases'));
    //         }
    //     });  
    //     $A.enqueueAction(action); 
    // },
   
})