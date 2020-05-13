({
	doInit: function(cmp, evt, help) {

		let recordId = cmp.get("v.recordId");

		if(help.isNotNull(recordId)){
			// console.log('record Yes');	
			help.getRecordsOnload(cmp, evt, recordId);
		}else{
			// console.log('record No');
			cmp.set("v.isNew",true);

			// Edit record from related List
			if(cmp.get("v.isChildMRedit")){
				help.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));
			}
			// avoid fetching all sObjects from Child Model pop up(Need Related Child sObjects)
			else if(cmp.get("v.isChildMR") ){
				help.getRelatedChildObjects(cmp, evt, cmp.get("v.ParentMatchingRule.Object_Name__c"));
				var ParentId = cmp.get("v.ParentMatchingRule.Id");
				cmp.set("v.MatchingRule.Parent_Matching_Rule__c", ParentId);
			}
			// get all SObjects onload(New Record)
			else{
				help.getALLsObjects(cmp, evt);
			}

			if(!cmp.get("v.isChildMRedit")){
				let MatchingRuleCreteria = [{
	                Field_Value__c: '',
	                Field_Type__c: '',
	                Field_API_Name__c: '',
	                Field_Operator__c: ''
	            }];
	            cmp.set('v.MatchingRuleCreteria', MatchingRuleCreteria);
	        }
		}
	},

	onSelectOfObject: function(cmp, evt, help){

		var selectedSObjectName = cmp.get("v.MatchingRule.Object_Name__c");
        console.log('selectedSObjectName>>>>>>>>> ',selectedSObjectName);
		help.getRelatedFields(cmp, selectedSObjectName);

		// condition not to get Child Objects from MR Creating from Model Pop up 
		if(!cmp.get("v.isChildMR")){
			help.getRelatedChildObjects(cmp, evt, selectedSObjectName);
		}

		if (cmp.get("v.isChildMR")) {
            var selectChildObjectName = cmp.get("v.MatchingRule.Object_Name__c");
            // console.log('selectChildObjectName>>>>>>>>>>>>',selectChildObjectName );
            cmp.set("v.selectChildObjectName",selectChildObjectName);
            let objectOptions = cmp.get("v.options");
            for (var i = 0; i < objectOptions.length; i++) {
                if (selectedSObjectName == objectOptions[i].value) {
                    cmp.set("v.MatchingRule.Relationship_Name__c", objectOptions[i].relationshipName);
                    break;
                }
            }
        }

	},

	// Add row
	handleAddRow: function (cmp, evt, help) {
        let rules = cmp.get('v.MatchingRuleCreteria');
        let obj = {
            Field_Value__c: '',
            Field_Type__c: '',
            Field_API_Name__c: '',
            Field_Operator__c: ''
        };
        rules.push(obj);
        cmp.set('v.MatchingRuleCreteria', rules);
    },

    // Form Evalution Order
    MatchingRuleCriteriaHandler: function (cmp, evt, help) {
    	let MatchingRuleCreteriaList = cmp.get('v.MatchingRuleCreteria');
        let evalOrder = '';

        MatchingRuleCreteriaList.forEach(function(ele){
            if(help.isNotNull(evalOrder)){
                evalOrder += ' AND '+ele.Line_Number__c;
            }else{
                evalOrder +=''+ele.Line_Number__c;
            }
        });
        
        let MatchingRule = cmp.get('v.MatchingRule');
        MatchingRule.Evaluation_Order__c = evalOrder;
        cmp.set('v.MatchingRule',MatchingRule);
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

    handlEdit: function (cmp, evt, help) {
    	// get All Related fields
        help.getRelatedFields(cmp, cmp.get("v.MatchingRule.Object_Name__c"));

    	cmp.set("v.isEdit", true);
    	cmp.set("v.isNew", true);
    },

    handleDelete: function (cmp, evt, help) {

        if (confirm('Do you want to DELETE '+cmp.get("v.MatchingRule.Name")+' record?')) {
        	var spinner = cmp.find('initSpinner');
        	$A.util.removeClass(spinner, "slds-hide");

            var action = cmp.get("c.deleteRecord");
            action.setParams({
                "recordId": cmp.get("v.MatchingRule.Id")
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

    // get values from Parent Matching Ruke lookUp field
    getValuesfromNewCMP: function (cmp, evt, help) {
        var relatedMRrecords = evt.getParam("relatedMRobject");
        cmp.set('v.RelatedMatchingRuleRecords', relatedMRrecords);
        $A.enqueueAction(cmp.get("c.handleCloseModel"));
    },

    getMRparentName: function (cmp, evt, help) {
        var Id = evt.getParam("Id");
        var fieldApi = evt.getParam("fieldApi");
        var ObjLabel = evt.getParam("ObjLabel");

        cmp.set("v.MatchingRule.Parent_Matching_Rule__c", Id);
        // console.log('Parent_Matching_Rule__r>>>>>> ',cmp.get('v.MatchingRule.ParentMatchingRule__c'));
    },

    redirectoParentMR: function (cmp, evt, help) {
    	// redirect in same tab
        // window.location.href = "/"+cmp.get('v.ParentMatchingRule.Id');

        // redirect to new tab
        window.open("/" + cmp.get('v.MatchingRule.Parent_Matching_Rule__r.Id'));
    },

    handleCreateChildMR: function (cmp, evt, help) {

        var modelId = cmp.find("modelId"); 
        $A.util.addClass(modelId , 'slds-show');
        $A.util.removeClass(modelId , 'slds-hide');

        $A.createComponent(
            "c:MatchingRule_CMP",
            {
                isChildMR: true,
                ParentMatchingRule: cmp.get("v.MatchingRule")
            },
            function (newButton, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body = [];
                    body.push(newButton);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },

    handlestoreRemovedrecordIds: function(cmp, evt, help){
    	let getRemovedIds = [];
        getRemovedIds = cmp.get("v.removedRowMRIds");
        var removedrowrecordId = evt.getParam("removedrowrecordId");
        getRemovedIds.push(removedrowrecordId);
        cmp.set("v.removedRowMRIds", getRemovedIds);
    },

    handleCloseModel: function(cmp, evt, help){
    	var modelId = cmp.find("modelId"); 
        $A.util.addClass(modelId , 'slds-hide');
        $A.util.removeClass(modelId , 'slds-show');
    }

})