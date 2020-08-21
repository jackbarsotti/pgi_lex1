({
	doInit: function(cmp, evt, help) {

		let recordId = cmp.get("v.recordId");

        let objectList = [{
                    value : 'Account',
                    label : 'Account'
                },
                {
                    value : 'Opportunity',
                    label : 'Opportunity'
                },
                {
                    value : 'OpportunityLineItem',
                    label : 'Opportunity Line Item'
                },
                {
                    value : 'Owner',
                    label : 'Owner'
                }];
                
        if(help.isNotNull(recordId)){
            cmp.set("v.isNew",false); 
            help.getCreatedRecords(cmp,evt);
        }else{
            cmp.set("v.isNew",true);
            // help.getALLsObjects(cmp, evt);
            cmp.set("v.options",objectList);
            // console.log('options>>>> ',cmp.get("v.options"));
        }

        let objOTE = [{
                    Object_Name__c : '',
                    Field_Name__c : '',
                    Field_Operator__c : '',
                    Field_Type__c : '',
                    Field_Value__c : ''
                }];
                cmp.set('v.OppyTeamRule', objOTE);

        let teamMembers = [{
                    OT_Member__c : '',
                    Role__c : '',
                    User__c : ''
                }];
                cmp.set('v.TeamMembers', teamMembers);

	},

	// Add row
	handleAddRow: function (cmp, evt, help) {
        let rules = cmp.get('v.OppyTeamRule');
        let obj = {
            Object_Name__c : cmp.get('v.options'),
                    Field_Name__c : '',
                    Field_Operator__c : '',
                    Field_Type__c : '',
                    Field_Value__c : ''
        };
        rules.push(obj);
        cmp.set('v.OppyTeamRule', rules);
         
    },

    // Form Evalution Order
    OppyTeamRuleHandler: function (cmp, evt, help) {
    	let OppyTeamRuleList = cmp.get('v.OppyTeamRule');
        let evalOrder = '';

        OppyTeamRuleList.forEach(function(ele){
            if(help.isNotNull(evalOrder)){
                evalOrder += ' AND '+ele.Line_Number__c;
            }else{
                evalOrder +=''+ele.Line_Number__c;
            }
        });
        
        let OTMember = cmp.get('v.OTMember');
        OTMember.Evaluation_Order__c = evalOrder;
        cmp.set('v.OTMember',OTMember);
    },

    // Save Records
    handleSaveRecord: function (cmp, evt, help) {
        help.saveRecords(cmp, evt, help);
    },

    handleCancel: function (cmp, evt, help) {

    	var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");
     	// console.time('Identifier>>>>>');
    	if(cmp.get("v.isNew") && !cmp.get("v.isEdit")){
    		// return to list view if Its new record
    		window.location.href = "/" + '' + cmp.get("v.sobjectKeyPrefix") + '/o';
    	}else{
    		// return back to record from edit state to read state of record
    		window.location.href = "/"+cmp.get('v.recordId');
    	}
    	// console.timeEnd('Identifier>>>>>');
    	$A.util.addClass(spinner, "slds-hide");
    },

    handleEdit: function (cmp, evt, help) {
    	cmp.set("v.isEdit", true);
    	cmp.set("v.isNew", true);
        
        let objectList = [{
                    value : 'Account',
                    label : 'Account'
                },
                {
                    value : 'Opportunity',
                    label : 'Opportunity'
                },
                {
                    value : 'OpportunityLineItem',
                    label : 'Opportunity Line Item'
                },
                {
                    value : 'Owner',
                    label : 'Owner'
                }];
        cmp.set("v.options",objectList);
    },

    handleDelete: function (cmp, evt, help) {

        if (confirm('Do you want to DELETE '+cmp.get("v.OTMember.Name")+' record?')) {
        	var spinner = cmp.find('initSpinner');
        	$A.util.removeClass(spinner, "slds-hide");

            var action = cmp.get("c.deleteRecord");
            action.setParams({
                "recordId": cmp.get("v.OTMember.Id")
            });
            action.setCallback(this, function (res) {
                let state = res.getState();
                if (state === "SUCCESS") {
                    let message = "Record Deleted Successfully";
                    help.showToastMessage(cmp, message, "SUCCESS");
                    window.location.href = "/" + '' + cmp.get("v.sobjectKeyPrefix") + '/o';
                }
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
        }
    },

    handleListView: function (cmp, evt, help) {
    	// return to list view
    	window.location.href = "/" + '' + cmp.get("v.sobjectKeyPrefix") + '/o';
    },

    handleRemovedOTRuleIds: function(cmp, evt, help){
    	let getRemovedOTRuleIds = [];
        getRemovedOTRuleIds = cmp.get("v.removedOTRuleIds");
        var removedOTRuleId = evt.getParam("removedOTRuleId");
        getRemovedOTRuleIds.push(removedOTRuleId);
        cmp.set("v.removedOTRuleIds", getRemovedOTRuleIds);
    },
    
    handleRemovedMemberIds: function(cmp, evt, help){
    	let getRemovedMemberIds = [];
        getRemovedMemberIds = cmp.get("v.removedOTRuleIds");
        var removedMemberId = evt.getParam("removedMemberId");
        getRemovedMemberIds.push(removedMemberId);
        cmp.set("v.removedMemberIds", getRemovedMemberIds);
    },

})