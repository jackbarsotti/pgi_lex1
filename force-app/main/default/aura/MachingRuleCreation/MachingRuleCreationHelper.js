({
    getALLsObjects : function(cmp, evt) {
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        
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
                // console.log('options>>>>>> ',JSON.parse(cmp.get("v.options")));
                
                $A.util.addClass(spinner, "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    getRelatedFields : function(cmp, evt, objlabel){
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.getALLFields");
        
        // let objName = cmp.get('v.MatchingRule');
        action.setParams({
            "objName" : objlabel
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                let fields = res.getReturnValue();
                // console.log('fields>>>>>> ',JSON.stringify(cmp.get("v.fields")));
                fields.sort((a, b) => (a.fieldLabel > b.fieldLabel) ? 1 : (a.fieldLabel === b.fieldLabel) ? ((a.fieldApiName > b.fieldApiName) ? 1 : -1) : -1 )
                cmp.set('v.fields',fields);
            }
            // console.log('fields>>>>>> ',cmp.get("v.fields"));
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }, 
    getRelatedChildRecords : function(cmp,evt, objlabel){
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        
        // let MatchingRule = cmp.get('v.MatchingRule');
        let action = cmp.get('c.getRelatedChildObjects');
        
        // console.log('inside child reccords>>>>>>>> ',objlabel);
        action.setParams({
            "objName" :  objlabel
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = res.getReturnValue();
                // console.log(JSON.parse(JSON.stringify(res))); 
                cmp.set('v.childMatchingRuleObjects',JSON.parse(JSON.stringify(res)));
                // console.log('childMatchingRuleObjects Name>>>>>>>> ',cmp.get('v.childMatchingRuleObjects'));
                
                $A.util.addClass(spinner, "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    getRecordsOnload : function(cmp, evt){
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide"); 

        var that = this;
        var returnObj;
        var getValuesfromCreateCMP;
        var cmpTarget = cmp.find("showChildRec");

        var action = cmp.get("c.getMatchingrecordonload");
        console.time('Indentifier>>>>1');

        action.setParams({
            "recordId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(res){
            var state = res.getState();

            if(state === 'SUCCESS'){
                returnObj = JSON.parse(res.getReturnValue());

                cmp.set("v.MatchingRule",returnObj.matchingRule);
                cmp.set("v.MatchingRuleCreation",returnObj.matchigRuleCriteria);
                cmp.set("v.RelatedMatchingRuleObject",returnObj.childMatchingRulerelatedObjects);
                cmp.set("v.CreatedMatchingRule",cmp.get("v.MatchingRule"));

                cmp.set('v.ParentMatchingRule.Id',cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Id"));
                cmp.set('v.ParentMatchingRule.Name',cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Name"));

                if(!that.isNotNull(cmp.get('v.ParentMatchingRule.Id'))){
                    $A.util.addClass(cmpTarget , 'slds-show');
                    $A.util.removeClass(cmpTarget , 'slds-hide');
                }

                getValuesfromCreateCMP = cmp.getEvent("getValuesfromCreateCMP");;
                    getValuesfromCreateCMP.setParams({
                        "isChildmatching" : false,
                        "relatedMRobject" :  cmp.get("v.RelatedMatchingRuleObject")
                    });
                getValuesfromCreateCMP.fire();

                that.getRelatedChildRecords(cmp, evt, cmp.get("v.MatchingRule.Object_Name__c"));

                $A.util.addClass(spinner, "slds-hide");
                console.timeEnd('Indentifier>>>>1');

            }
        });
        $A.enqueueAction(action);
    },
    saveRecords : function(cmp, help, evt){
        
        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        
        let MatchingRule = cmp.get('v.MatchingRule');
        let matchingRuleCriteria = cmp.get('v.MatchingRuleCreation');
        let message;
        let messageType;
        var returnObj;
        var getValuesfromCreateCMP;
        let that = this;
        var cmpTarget = cmp.find("showChildRec"); 
        var modelpopup = cmp.find("showModelPopup");

        var action = cmp.get("c.createNewRecords");
        console.time('Indentifier>>>>');
        // To pass 1st CMP Matching Rule record to 2nd CMP and making recordId null to create New Matching rule 
        if((!cmp.get("v.setOutput") && cmp.get("v.isChildMR")) || cmp.get('v.isChildMRedit')){
            MatchingRule.Parent_Matching_Rule__c = cmp.get("v.CreatedMatchingRule.Id");
            cmp.set("v.MatchingRule",MatchingRule);

        }
        
        // exicutes when record is edited
        // if(!cmp.get("v.setOutput") && !cmp.get("v.isChildMR")){
        //     cmp.set("v.recordId",null)
        // }
        
        action.setParams({
            // "recordId" : cmp.get("v.recordId"),
            "matchingRule" : JSON.stringify(MatchingRule), 
            "matchigRuleCriteria" : JSON.stringify(matchingRuleCriteria),
            "removeRowRecordIds" : cmp.get("v.removeRowMatchingruleList")
        });
        action.setCallback(this, function(res){
            // var resultsToast = $A.get("e.force:showToast");
            
            var state = res.getState();
            // console.log('state>>>>>>>>> ',state);
            
            if(state === 'SUCCESS'){
                returnObj = JSON.parse(res.getReturnValue());
                // console.log('returnObj---after===>',returnObj);
                // let childRules = returnObj.matchigRuleCriteria;
                // to show "Child Matching Records" related list on 1st CMP  when isChildMR is FALSE
                
                
                // console.log('setOutput>>>>>>>>>> ',cmp.get("v.setOutput"));
                // console.log('isEdit>>>>>>>>>> ',cmp.get("v.isEdit"));
                // console.log('isChildMR>>>>>>>>>> ',cmp.get("v.isChildMR"));

                // after edit record
                if(!(cmp.get('v.setOutput')) && cmp.get("v.isEdit")){
                    cmp.set('v.setOutput',!(cmp.get('v.setOutput')));
                    message = 'Record Updated Successfully';
                    messageType = 'SUCCESS';

                    console.log('isChildMR>>>inside>>>>>>> ',cmp.get("v.isChildMR"));
                    // to close popup model after saving record
                    cmp.set("v.isChildMR",false)

                    that.showToastMessage(cmp , message, messageType);
                }

                // After Inserted new record, After save return back to created record
                if(!(cmp.get('v.setOutput'))){
                    cmp.set('v.setOutput',!(cmp.get('v.setOutput')));
                    message = 'Record Created Successfully';
                    messageType = 'SUCCESS';
                    // cmp.set("v.isChildMR",true);
                    that.showToastMessage(cmp , message, messageType);
                }
                
                //console.log('returnObj---before===>',returnObj);
                
                // console.log('returnObj>>>MRCretriea>>>>>> ',returnObj.matchigRuleCriteria);
                
                // console.log('isChildMR>>>>>>>>> ',cmp.get("v.isChildMR"));
                // console.log('childMatchingRulerelatedObjects>>>>>>>>> ',returnObj.childMatchingRulerelatedObjects);
                
                // to get all Matching rule records in Related list
                // if(cmp.get('v.setOutput')){
                //     cmp.set("v.RelatedMatchingRuleObject",returnObj.childMatchingRulerelatedObjects);
                //     // console.log('RelatedMatchingRuleObject>>>>>>>> ',cmp.get("v.RelatedMatchingRuleObject"));
                // }
                
                // if((cmp.get('v.setOutput') && cmp.get("v.isChildMR")) || cmp.get('v.isChildMRedit')){
                    
                //     // To hide pop Up
                //     cmp.set("v.isChildMR",false);
                    
                //     // cmp Event to pass created Matching rule to store in related list
                //     getValuesfromCreateCMP = cmp.getEvent("getValuesfromCreateCMP");;
                //     getValuesfromCreateCMP.setParams({
                //         "isChildmatching" : cmp.get("v.isChildMR"),
                //         "relatedMRobject" :  cmp.get("v.RelatedMatchingRuleObject")});
                //     getValuesfromCreateCMP.fire();
                // }
                
                // cmp.set("v.MatchingRuleCreationCloned",returnObj.matchigRuleCriteria);
                // console.log('MatchingRuleCreationCloned><>>>>>cloned>>>>>>> ',cmp.get("v.MatchingRuleCreationCloned"));
                
                cmp.set("v.MatchingRule",returnObj.matchingRule);
                cmp.set("v.MatchingRuleCreation",returnObj.matchigRuleCriteria);
                
                // To pass 1st CMP Matching Rule record to 2nd CMP
                // if(cmp.get('v.setOutput') && !cmp.get("v.isChildMR")){
                //     cmp.set("v.CreatedMatchingRule",cmp.get("v.MatchingRule"));
                //     // console.log('CreatedMatchingRule>>>>>>>> ',cmp.get("v.CreatedMatchingRule"));
                // }
                
                // cmp.set('v.ParentMatchingRule.Id',cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Id"));
                // cmp.set('v.ParentMatchingRule.Name',cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Name"));
                
                // let that1 = this;
                // if(cmp.get('v.setOutput'))
                //     that1.getRelatedChildRecords(cmp, evt, cmp.get("v.MatchingRule.Object_Name__c"));
                
                // To hide the "Child Matching Records" related list when MR record had lookup to Parent matching rule
                if(!that.isNotNull(cmp.get("v.MatchingRule.Parent_Matching_Rule__r.Id"))){
                    $A.util.addClass(cmpTarget , 'slds-show');
                    $A.util.removeClass(cmpTarget , 'slds-hide');
                }else{
                    $A.util.addClass(cmpTarget , 'slds-hide');
                    $A.util.removeClass(cmpTarget , 'slds-show');
                }

                console.log('isChildMR>>>>>>After>>>> ',cmp.get("v.isChildMR"));
                
            } else if(state === "ERROR"){
                console.log('state in error>>>>>>>> ',state);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        // ERROR message after record inserted/Updated
                        message = errors[0].message;
                        that.showToastMessage(cmp, message, "ERROR");
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }

            $A.util.addClass(spinner, "slds-hide");

            console.timeEnd('Indentifier>>>>');
        });
        $A.enqueueAction(action);
    },
    FormEvaluationOrder : function(cmp, evt){
        let matchingRuleCreationList = cmp.get('v.MatchingRuleCreation');
        let evalOrder = '';
        let that = this;
        matchingRuleCreationList.forEach(function(ele){
            if(that.isNotNull(evalOrder)){
                evalOrder += ' AND '+ele.Line_Number__c;
            }else{
                evalOrder +=''+ele.Line_Number__c;
            }
        });
        
        let MatchingRule = cmp.get('v.MatchingRule');
        MatchingRule.Evaluation_Order__c = evalOrder;
        cmp.set('v.MatchingRule',MatchingRule);
    },
    isNotNull : function(value){
        return  value != undefined &&  value != null && value != '' ? true : false;
    },

    showToastMessage : function(cmp , message, messageType){
        // console.log('message>>>>>>>>>>> ',message);
        // console.log('messageType>>>>>>>>>>> ',messageType);
        $A.createComponent(
            "c:ClassicToastMessage",
            { 
                "message" : message,
                "messageType" : messageType
            },
            function(newInp, status, errorMessage){
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
                    //console.log('inside body');
                }
                else if (status === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.")
                }
                    else if (status === "ERROR") {
                        //console.log("Error: " + errorMessage);
                    }
            }
        );
    },  

    backtoMRlistview : function (cmp, evt, help) {

        var action = cmp.get("c.getObjectKeyPrefix");
            action.setCallback(this, function (res) {

                let state = res.getState();
                if (state === 'SUCCESS') {
                    let keypreficMR = res.getReturnValue();
                    window.location.href = "/" + '' + keypreficMR + '/o';
                }
            });
            $A.enqueueAction(action);
            
    },
    
    
    
})