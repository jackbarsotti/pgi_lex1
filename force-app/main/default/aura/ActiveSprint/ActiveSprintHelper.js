({//Addedthis because when sorting order call the do init.
    
    getActiveAgileSprint : function(component, event, helper,field,order) {
        var promise = new Promise(function(resolve,reject){
            var action = component.get("c.getActiveAgiles");
            action.setParams({
                "objName": component.get("v.objName"),
                "objFields": component.get("v.objFields"),
                "kanbanField": component.get("v.agileStatusOnCase"),
                "isForBackLog":component.get("v.isForBackLog"),
                "selectedGroup":component.get('v.groupSelected'),
                "field":field,
                "order":order
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve("true");
                    component.set("v.kanbanData", response.getReturnValue());
                    component.set('v.allRecords',component.get('v.kanbanData.records'));
                    var picklist = component.get('v.kanbanData.pickVals');
                 
                }
                else{
                    reject("false");
                }
            });
            $A.enqueueAction(action);
        });
        return promise;
    },
    //to get the map of group and agile status
    getStatusRelatedTogroup : function(component, event, helper) {
        var action = component.get("c.getAgileStatusToGroup");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.groupToAgileStatus',response.getReturnValue());
                if(!component.get('v.isForBackLog')){
                    var map = component.get('v.groupToAgileStatus');
                    component.set('v.kanbanData.pickVals',map[component.get('v.groupSelected')]);
                    helper.hideSpinner( component );
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Not required
    // getAllSprint : function(component, event, helper) {
    //     var action = component.get("c.getallSprint");
    //     action.setCallback(this, function(response) {
    //         console.log('Testing13',response.getState());
    //         if (response.getState() == "SUCCESS") {
    //             console.log('Testing123');
    //             var allValues = response.getReturnValue();
    //             component.set('v.allSprint', allValues);
    //             console.log('Testing111',component.get('v.allSprint'));
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    
    getgroupPicklist : function(component, event, helper) {
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            "ObjectApi_name" : 'AgileSprint__c',
            "Field_name" : 'AssociatedGroup__c'
        });
        action.setCallback(this, function(response) {
            console.log('Testing13',response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set('v.picklistOptions', allValues);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    updatePickVal : function(component, recId, pField, pVal,helper) {
        //Id recId, String kanbanField, String kanbanNewValue
        var action = component.get("c.getUpdateStage");
        action.setParams({
            "recId":recId,
            "kanbanField":pField,
            "kanbanNewValue":pVal,
            "isForBackLog":component.get("v.isForBackLog"),
            "groupselected":component.get("v.groupSelected")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: ',state);
            if (state === "SUCCESS") {
                // //Load Records
                document.getElementById(recId).style.backgroundColor = "#ffb75d";
                this.getActiveAgileSprint(component, event, helper,component.get('v.fieldToSort'),component.get('v.fieldOrder')).then(
                    $A.getCallback(function(result){
                        
                        // Added because of Show onLy Me and Show All
                        var records = component.get('v.allRecords');
                        var label = component.find( "switchUser" ).get( "v.label" );
                        var userId = $A.get("$SObjectType.CurrentUser.Id"); 
                        if(label == 'Show only mine'){
                            component.set('v.kanbanData.records',records);
                        }
                        else{
                            var newArray = [];
                            for(var key in records){
                                if(records[key].Assigned_To__c == userId || records[key].AgileTester__c == userId){
                                    newArray.push(records[key]);
                                }
                            }
                            component.set('v.kanbanData.records',newArray); 
                        }
                        // End
                        if(!component.get('v.isForBackLog')){
                            var map = component.get('v.groupToAgileStatus');
                            component.set('v.kanbanData.pickVals',map[component.get('v.groupSelected')]);
                            helper.hideSpinner( component );
                        }
                        else{
                            helper.hideSpinner( component );
                        }
                    })
                )
               
                //
                document.getElementById(recId).style.backgroundColor = "#04844b";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 1);
                // document.getElementById(recId).style.backgroundColor = "";
            }
        });
        $A.enqueueAction(action);
    },
    
    setAgileStatus : function(component, event, helper) {
        var promise = new Promise(function(resolve,reject){
            var action = component.get("c.updateStatus");
            action.setParams({
                "sprintName" : event.getSource().get("v.title"),
                "name" : event.getSource().get("v.label"),
                "groupSelected" : event.getSource().get("v.name")
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else{
                    reject("false");
                }
            });
            $A.enqueueAction(action);
        });
        return promise;
    },
    //check group is active.
    checkGroupActive : function(component, event, helper) {
        var action = component.get("c.getGroupToStatus");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                component.set('v.checkGroupActive',response.getReturnValue());
                var map = component.get('v.checkGroupActive');
                component.set('v.isStart',map[component.get('v.groupSelected')]);
            }
            else{
            }
        });
        $A.enqueueAction(action);
    },
    
    getSprintStatus : function(component, event, helper) {
        var action = component.get("c.getAgileNameToStatus");
        action.setCallback(this, function(response) {
            console.log('Status12');
            if (response.getState() == "SUCCESS") {
                
                var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                component.set("v.checkButtonStatus", custs);
                helper.hideSpinner( component );
            }
            else{
            }
        });
        $A.enqueueAction(action);
    },

    setPrecision : function(component,contactData,data,sprintName,event, helper,index,count) {
        //here index is only for checking if we drag to bottomEnd(ie below li in Active Sprint)if undefined then it is out of li
        //count is 1 means we should not Load spinner(Ie only one caseCard if we drag that in same sprint then we do nothing)
       if(index == undefined && count != 1){
        //    console.log('Getting');
        helper.showSpinner( component );
       }
        var action = component.get("c.setPrecision"); 
        action.setParams({
            "caseLst" : contactData,
            "sprintName" : sprintName,
            "caseId" : data,
            "isBacklof" : component.get('v.isForBackLog'),
            "Index" : index
        });
        action.setCallback(this, function(response) {
            console.log('Status12');
            if (response.getState() == "SUCCESS") {
                
                
                console.log('The Status12 res12345',component.get("v.checkButtonStatus"));
                if(index == undefined && count != 1){
                    this.getActiveAgileSprint(component, event, helper,component.get('v.fieldToSort'),component.get('v.fieldOrder')).then(
                        $A.getCallback(function(result){
                            // Added because of Show onLy Me and Show All
                        var records = component.get('v.allRecords');
                        var label = component.find( "switchUser" ).get( "v.label" );
                        var userId = $A.get("$SObjectType.CurrentUser.Id"); 
                            if(label == 'Show only mine'){
                                component.set('v.kanbanData.records',records);
                            }
                            else{
                                var newArray = [];
                                for(var key in records){
                                    if(records[key].Assigned_To__c == userId || records[key].AgileTester__c == userId){
                                        newArray.push(records[key]);
                                    }
                                }
                                component.set('v.kanbanData.records',newArray); 
                            }

                            if(!component.get('v.isForBackLog')){
                                var map = component.get('v.groupToAgileStatus');
                                component.set('v.kanbanData.pickVals',map[component.get('v.groupSelected')]);
                                helper.hideSpinner( component );
                            }
                            else{
                                helper.hideSpinner( component );
                            }
                        })
                    )
                   
                   }
            }
            else{
                console.log('The return1234');
            }
        });
        $A.enqueueAction(action);
    },


    hideSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.addClass( eleSpinner, "slds-hide" );
    },
    showSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.removeClass( eleSpinner, "slds-hide" );
    },
})