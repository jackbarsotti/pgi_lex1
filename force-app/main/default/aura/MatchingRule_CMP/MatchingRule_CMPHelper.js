({
    getRecordsOnload: function(cmp, evt, recordId) {
        let action = cmp.get('c.getRecords');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(res.getReturnValue());
                cmp.set("v.MatchingRule",res.matchingRule);
                cmp.set("v.MatchingRuleCreteria",res.matchigRuleCriteria);
                cmp.set("v.RelatedMatchingRuleRecords",res.childMatchingRuleRelatedRecords);
                // console.log('RelatedMatchingRuleRecords>>>>>>> ',cmp.get("v.RelatedMatchingRuleRecords"));

                if(cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Id")){
                    cmp.set("v.isParentExists",true);
                }
            }
        });
        $A.enqueueAction(action);
    },

	getALLsObjects: function(cmp, evt) {

        let action = cmp.get('c.getallobjects');
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = res.getReturnValue();
                let objectsList = JSON.parse(res);
                objectsList.sort(function(a, b) {
                    var x = a.label.toLowerCase();
                    var y = b.label.toLowerCase();
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                });
                cmp.set('v.options',objectsList);
            }
        });
        $A.enqueueAction(action);
    },

    getRelatedFields: function(cmp, sObjectName) {
        console.log('getALLFields>>>>> ',cmp.get("v.isNew"));
    	var action = cmp.get("c.getALLFields");
        action.setParams({
            "objName" : sObjectName
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                let fields = res.getReturnValue();
                fields.sort((a, b) => (a.fieldLabel > b.fieldLabel) ? 1 : (a.fieldLabel === b.fieldLabel) ? ((a.fieldApiName > b.fieldApiName) ? 1 : -1) : -1 )
                cmp.set('v.relatedFields',fields);
                // console.log('relatedFields>>>>>>> ',JSON.parse(JSON.stringify(fields)));
            }
            return ;
        });
        $A.enqueueAction(action);

    },

    getRelatedChildObjects : function(cmp, evt, sObjectName) {

    	let action = cmp.get('c.getRelatedChildObjects');
    	action.setParams({
            "objName" :  sObjectName
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = res.getReturnValue();
                cmp.set('v.relatedChildObjects',JSON.parse(JSON.stringify(res)));
                // console.log('relatedChildObjects>>>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.relatedChildObjects"))));
                if(cmp.get("v.isChildMR")){
                    cmp.set('v.options',cmp.get("v.relatedChildObjects"));
                }
            }
            return ;
        });
        $A.enqueueAction(action);
    },

    saveRecords : function(cmp, evt, help) {
        var message;

        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");

        let MatchingRule = cmp.get('v.MatchingRule');
        let MatchingRuleCreteria = cmp.get('v.MatchingRuleCreteria');

        let action = cmp.get("c.saveMatchingRecords");
        action.setParams({
            "matchingRule" : JSON.stringify(MatchingRule), 
            "matchigRuleCriteria" : JSON.stringify(MatchingRuleCreteria),
            "removedRowMRIds": cmp.get("v.removedRowMRIds")
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var returnObj = JSON.parse(res.getReturnValue());

                if(cmp.get("v.isChildMRedit")){
                    message = 'Record Updated Successfully';
                    this.showToastMessage(cmp, message, 'SUCCESS');

                    cmp.set("v.RelatedMatchingRuleRecords",returnObj.childMatchingRuleRelatedRecords);
                    var getValuesfromCreateCMP = cmp.getEvent("getValuesfromCreateCMP");;
                    getValuesfromCreateCMP.setParams({
                        "relatedMRobject" :  cmp.get("v.RelatedMatchingRuleRecords")
                    });
                    getValuesfromCreateCMP.fire();
                }
                // from model pop up
                else if(cmp.get("v.isChildMR")){
                    message = 'Record Created Successfully';
                    this.showToastMessage(cmp, message, 'SUCCESS');

                    cmp.set("v.RelatedMatchingRuleRecords",returnObj.childMatchingRuleRelatedRecords);
                    var getValuesfromCreateCMP = cmp.getEvent("getValuesfromCreateCMP");;
                    getValuesfromCreateCMP.setParams({
                        "relatedMRobject" :  cmp.get("v.RelatedMatchingRuleRecords")
                    });
                    getValuesfromCreateCMP.fire();
                }
                else if(cmp.get("v.isEdit")){
                    // if(cmp.get("v.RelatedMatchingRuleRecords").length == 0){
                        window.location.href = "/"+returnObj.matchingRule.Id;
                    // }
                    message = 'Record Updated Successfully';
                    this.showToastMessage(cmp, message, 'SUCCESS');
                }
                else{
                    window.location.href = "/"+returnObj.matchingRule.Id;
                    message = 'Record Created Successfully';
                    this.showToastMessage(cmp, message, 'SUCCESS');
                }

                cmp.set("v.isNew",false);
                cmp.set("v.isEdit",false);

                // App event to hide modelPopup from Relatedlist edit button
                if(cmp.get("v.isChildMRedit")){
                    // message = 'Record Updated Successfully';
                    // this.showToastMessage(cmp, message, 'SUCCESS');

                    var closeEditModelfromParent = $A.get("e.c:closeEditModelfromParent");
                    closeEditModelfromParent.fire();
                }
                
            }
            else if(state === "ERROR"){
                console.log('state in error>>>>>>>> ',state);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        // ERROR message after record inserted/Updated
                        message = errors[0].message;
                        this.showToastMessage(cmp, message, "ERROR");
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }

            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    },

    // check null values
    isNotNull : function(value){
        return  value != undefined &&  value != null && value != '' ? true : false;
    },

    // toast message display
    showToastMessage : function(cmp , message, messageType){
        $A.createComponent(
            "c:ClassicToastMessage",
            { 
                "message" : message,
                "messageType" : messageType
            },
            function(newInp, status, errorMessage){
                // console.log('status>>>>>>>>>>> ',status);
                if (status === "SUCCESS") {
                    // var body = cmp.get("v.body");
                    // body.push(newInp);
                    // cmp.set("v.body", body);
                    var container = cmp.find("toastMessageBody");
                    //var containerBody = cmp.get("v.body");
                    //var thisComponent = newInp;
                    let body = [];
                    body.push(newInp);
                    //container.push(newInp);
                    container.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("incomplete: " + errorMessage);
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
            }
        );
    }, 
	
    getMRKeyPrefix : function(component) {
        var action = component.get("c.getObjectKeyPrefix");
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === 'SUCCESS') {
                let keypreficMR = res.getReturnValue();
                component.set("v.sobjectKeyPrefix",keypreficMR);
            }
        });
        $A.enqueueAction(action);
    },

 })