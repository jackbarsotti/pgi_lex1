({
 
    // function call on cmp Load
    doInit: function(cmp, event, helper) {
        helper.getMemberRoles(cmp, event);
        // console.log('TeamMembers>>>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.TeamMembers"))));
        // helper.createObjectData(cmp, event);
    },
    
    // Form Evalution Order
    TeamMemberhandler: function (cmp, evt, help) {
    	// let OppyTeamRuleList = cmp.get('v.OppyTeamRule');
     //    let evalOrder = '';

     //    OppyTeamRuleList.forEach(function(ele){
     //        if(help.isNotNull(evalOrder)){
     //            evalOrder += ' AND '+ele.Line_Number__c;
     //        }else{
     //            evalOrder +=''+ele.Line_Number__c;
     //        }
     //    });
        
     //    let OppyTeamMember = cmp.get('v.OppyTeamMember');
     //    OppyTeamMember.Evaluation_Order__c = evalOrder;
     //    cmp.set('v.OppyTeamMember',OppyTeamMember);
    },

    handleAddRow: function (cmp, evt, help) {
        let members = cmp.get('v.TeamMembers');
        let TeamMembers = {
                    OT_Member__c : '',
                    Role__c : '',
                    User__c : ''
                };
        members.push(TeamMembers);
        cmp.set('v.TeamMembers', members);
    },
 
    // function for save the Records 
    Save: function(cmp, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if (helper.validateRequired(cmp, event)) {
            // call the apex class method for save the Contact List
            // with pass the contact List attribute to method param.  
            var action = cmp.get("c.saveContacts");
            action.setParams({
                "ListContact": cmp.get("v.contactList")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if response if success then reset/blank the 'contactList' Attribute 
                    // and call the common helper method for create a default Object Data to Contact List 
                    cmp.set("v.contactList", []);
                    helper.createObjectData(cmp, event);
                    alert('record Save');
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
    },
 
    // function for create new object Row in Contact List 
    addNewRow: function(cmp, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(cmp, event);
    },
 
    // function for delete the row 
    removeDeletedRow: function(cmp, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = cmp.get("v.contactList");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        cmp.set("v.contactList", AllRowsList);
    },
})