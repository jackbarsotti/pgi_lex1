({
    doInit: function (cmp, evt, help) {
        var recordId = cmp.get("v.recordId");
        //console.log('recordId>>>>doinit>>> ',cmp.get("v.recordId"));

        if (recordId && !cmp.get("v.isChildMRedit")) {
            cmp.set("v.setOutput", true);
            help.getRecordsOnload(cmp, evt, help);
        }

        // if (recordId && !cmp.get("v.isChildMRedit")) {
        //     cmp.set("v.setOutput", true);
        //     help.saveRecords(cmp, evt);
        // }

        // console.log('isChildMRedit>>doinit>>>>> ',cmp.get("v.isChildMRedit"));
        if (!cmp.get("v.isChildMRedit")) {
            let MatchingRuleCreation = [{
                Field_Value__c: '',
                Field_Type__c: '',
                Field_API_Name__c: '',
                Field_Operator__c: ''
            }];
            cmp.set('v.MatchingRuleCreation', MatchingRuleCreation);
        }

        //console.log('MatchingRuleCreation>>doinit>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.MatchingRuleCreation"))));
        // console.log('isChildMR>>doinit>>>>> ',cmp.get("v.isChildMR"));
        if (!cmp.get("v.isChildMR")){
            help.getALLsObjects(cmp, evt);
        }else{
            let objlabel = cmp.get("v.CreatedMatchingRule.Object_Name__c");
            help.getRelatedChildRecords(cmp, evt, objlabel);
        }

        if (cmp.get("v.isChildMRedit"))
            help.getRelatedFields(cmp, evt, cmp.get("v.MatchingRule.Object_Name__c"));
    },

    onSelectOfObject: function (cmp, evt, help) {
        cmp.set('v.hideMatchingRuleCriteria', false);
        let objlabel = cmp.get("v.MatchingRule.Object_Name__c");
        help.getRelatedFields(cmp, evt, objlabel);
        if (!cmp.get("v.isChildMR"))
            help.getRelatedChildRecords(cmp, evt, objlabel);

        if (cmp.get("v.isChildMR")) {
            var selectChildObjectName = cmp.get("v.MatchingRule.Object_Name__c");
            // console.log('selectChildObjectName>>>>>>>>>>>>',selectChildObjectName );
            cmp.set("v.selectChildObjectName",selectChildObjectName);
            let objectOptions = cmp.get("v.options");
            for (var i = 0; i < objectOptions.length; i++) {
                if (objlabel == objectOptions[i].value) {
                    cmp.set("v.MatchingRule.Relationship_Name__c", objectOptions[i].relationshipName);
                    break;
                }
            }
        }
        //help.enableSaveRecord(cmp, evt);

    },
    handleClick: function (cmp, evt, help) {
        let rules = cmp.get('v.MatchingRuleCreation');
        let obj = {
            Field_Value__c: '',
            Field_Type__c: '',
            Field_API_Name__c: '',
            Field_Operator__c: ''
        };
        rules.push(obj);
        cmp.set('v.MatchingRuleCreation', rules);
    },

    handleComponentEvent: function (cmp, evt, help) {
        var message = evt.getParam("indexOfRow");
        //console.log(message);
    },

    CreateChildMR: function (cmp, evt, help) {
        // cmp.set('v.isShowModel',true);
        cmp.set("v.isChildMR", true);

        /*var cmpTarget = cmp.find("showModel");
        $A.util.addClass(cmpTarget , 'slds-show');
        $A.util.removeClass(cmpTarget , 'slds-hide');
        */

        // console.log('childMatchingRuleObjects><<<<<<<<>>>>>>>>>> ',cmp.get("v.childMatchingRuleObjects"));
        // console.log('MatchingRule><<<<<<<<>>>>>>>>>> ',JSON.stringify(cmp.get("v.CreatedMatchingRule")));
        // console.log('RelatedMatchingRuleObject><<<<<<<<>>>>>>>>>> ',cmp.get("v.RelatedMatchingRuleObject"));

        $A.createComponent(
            "c:MachingRuleCreation",
            {
                options: cmp.get("v.childMatchingRuleObjects"),
                isChildMR: true,
                RelatedMatchingRuleObject: cmp.get("v.RelatedMatchingRuleObject"),
                CreatedMatchingRule: cmp.get("v.CreatedMatchingRule")
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

    saveResult: function (cmp, evt, help) {
        help.saveRecords(cmp, help, evt);
    },
    closeModel: function (cmp, evt, help) {
        cmp.set("v.isChildMR", false);

    },
    editRecord: function (cmp, evt, help) {
        cmp.set("v.setOutput", false);
        cmp.set("v.isEdit", true);
        var parentid = cmp.find('parentid');

        //console.log('inEdit>>>>>>>> ',cmp.get("v.ParentMatchingRule.Name"));
        //console.log('isNotNull>>>>>>>>>> ',help.isNotNull(cmp.get("v.ParentMatchingRule.Name")));
        if (help.isNotNull(cmp.get("v.ParentMatchingRule.Name"))) {
            $A.util.removeClass(parentid, 'slds-hide');
            $A.util.addClass(parentid, 'slds-show');
        }
        else if (cmp.get("v.RelatedMatchingRuleObject").length == 0) {
            $A.util.removeClass(parentid, 'slds-hide');
            $A.util.addClass(parentid, 'slds-show');
        }
        else {
            $A.util.addClass(parentid, 'slds-hide');
            $A.util.removeClass(parentid, 'slds-show');
        }

        // To get SObject options after edit 
        help.getALLsObjects(cmp, evt);
        let objlabel = cmp.get("v.MatchingRule.Object_Name__c");
        cmp.set("v.selectedChildObject",objlabel);
        help.getRelatedFields(cmp, evt, objlabel);
    },
    cancelEdit: function (cmp, evt, help) {

        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");

        // console.log('Id>>>>>> ',cmp.get("v.MatchingRule.Id"));

        if (help.isNotNull(cmp.get("v.MatchingRule.Id"))) {

            var action = cmp.get("c.getMatchingrecordonload");
            action.setParams({
                "recordId": cmp.get("v.recordId")
            });
            action.setCallback(this, function (res) {
                let returnObj;
                var state = res.getState();
                // console.log('state>>>>>> ',state);
                if (state === 'SUCCESS') {
                    // console.log('returnObj>>>>>> ',res.getReturnValue());
                    returnObj = JSON.parse(res.getReturnValue());
                    cmp.set("v.MatchingRuleCreation", returnObj.matchigRuleCriteria);
                    cmp.set("v.setOutput", true);
                }
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);

        }
        else {

            help.backtoMRlistview(cmp, evt, help);
        }

    },

    backtolist : function (cmp, evt, help) {

        help.backtoMRlistview(cmp, evt, help);

    },
    enableSave: function (cmp, evt, help) {
        //help.enableSaveRecord(cmp, evt);
    },
    deleteRecord: function (cmp, evt, help) {
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");

        if (confirm('Do you want to DELETE this record?')) {
            var action = cmp.get("c.deleteMatchingRuleRecord");
            //console.log('MatchingRule>>>>>> ',cmp.get("v.MatchingRule.Id"));
            action.setParams({
                "recordId": cmp.get("v.MatchingRule.Id")
            });
            action.setCallback(this, function (res) {
                let state = res.getState();
                if (state === "SUCCESS") {
                    let keypreficMR = res.getReturnValue();
                    let message = "Record Deleted Successfully";
                    help.showToastMessage(cmp, message, "SUCCESS");
                    window.location.href = "/" + '' + keypreficMR + '/o';
                }
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
        }

    },
    MatchingRuleCriteriaHandler: function (cmp, evt, help) {
        help.FormEvaluationOrder(cmp, evt);
    },

    getValuesfromNewCMP: function (cmp, evt, help) {
        var isChildmatching = evt.getParam("isChildmatching");
        var relatedMRobject = evt.getParam("relatedMRobject");
        cmp.set('v.isChildMR', isChildmatching);
        cmp.set('v.RelatedMatchingRuleObject', relatedMRobject);
        // console.log('isChildmatching>>>>> ',isChildmatching);
        // console.log('relatedMRobject>>>>> ',relatedMRobject);
    },

    getMRparentName: function (cmp, evt, help) {
        var Id = evt.getParam("Id");
        var fieldApi = evt.getParam("fieldApi");
        var ObjLabel = evt.getParam("ObjLabel");
        cmp.set("v.ParentMatchingRule.Name", ObjLabel);
        cmp.set("v.ParentMatchingRule.fieldAPIname", fieldApi);
        cmp.set("v.ParentMatchingRule.Id", Id);

        // console.log('ParentMatchingRule>>>>>>> Id>>>>>>>> ',cmp.get('v.ParentMatchingRule.Id'));
        cmp.set("v.MatchingRule.Parent_Matching_Rule__c", cmp.get("v.ParentMatchingRule.Id"));
        // console.log('MatchingRule>>>>>>> Id>>>>>>>> ',cmp.get('v.MatchingRule.ParentMatchingRule__c'));

    },

    redirectoParentMR: function (cmp, evt, help) {

        // redirect in same tab
        // window.location.href = "/"+cmp.get('v.ParentMatchingRule.Id');

        // redirect to new tab
        window.open("/" + cmp.get('v.ParentMatchingRule.Id'));
    },

    handlestoreRemovedrecordIds: function (cmp, evt, help) {

        let getRemovedIds = [];
        getRemovedIds = cmp.get("v.removeRowMatchingruleList");
        var removedrowrecordId = evt.getParam("removedrowrecordId");
        getRemovedIds.push(removedrowrecordId);
        cmp.set("v.removeRowMatchingruleList", getRemovedIds);
        //console.log('removeRowMatchingruleList><>>>>>>>>>>>> ',cmp.get("v.removeRowMatchingruleList"));

    }

})