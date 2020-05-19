({
    getAgreementTemplate : function(component, event, helper) {
        var result;
        var actionAT = component.get("c.getAgreementTemplateData");
        actionAT.setCallback(this, function(response){
            var state = response.getState();
            console.log('state for AT: ',state);
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                // console.log('>> result in AT length >>',result.length);
                // console.log('>> result in AT size>>',result.Size());
                // if(result.length > 0){
                    // console.log('>> else >>');
                    // var result = helper.getAgreementTemplate(component, event);
                    console.log('>> result in getAT >>',result);
                    var id = component.get('v.recordId');
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId='+id+'&TemplateId='+result.Id
                    });
                    urlEvent.fire();
                    console.log('>> after fire event >>');
                // }
            }
        });
        $A.enqueueAction(actionAT);
    },    
    getSignAgreement : function(component, event, helper) {
        var action = component.get("c.getSignAgreementData");
        action.setParams({
            oppId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state for sign Agreement: ',state);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.SignAgreementList",res);
                console.log('>> res >>',res.length);
                if(res.length >= 1){
                    // helper.showToast(component,event,'There is already an open Adobe Agreement against this opportunity');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : 'warning',
                        "message": "There is already an open Adobe Agreement against this opportunity."
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },    
    getOpportunity : function(component, event, helper) {
        // var result;
        // var actionAT = component.get("c.getAgreementTemplateData");
        // actionAT.setCallback(this, function(response){
        //     var state = response.getState();
        //     console.log('state: ',state);
        //     if (state === "SUCCESS") {
        //         result = response.getReturnValue();
        //     }
        // });

        var action = component.get("c.getOpportunityData");
        action.setParams({
            oppId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('>> state :  ',state);
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();
                console.log('>> opp in getOppp >>',opp);
                helper.getSignAgreement(component, event);
                // var SignAgreement =  component.get("v.SignAgreementList");
                // Console.log('>> SignAgreement length >>',SignAgreement.length);
                if(opp.StageName == 'Awareness'){
                    helper.showToast(component,event,'eSignature is not available for opportunities that are in the Awareness stage. Please move this opportunity beyond Awareness before using eSignature.');
                }else if(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won' ){
                    helper.showToast(component,event,'eSignature is not available for Closed opportunities.');
                }
                else{
                    console.log('>> else >>');
                    // if(opp.Primary_Won_Reason__c == '' || opp.Secondary_Won_Reason__c == '' || opp.Tertiary_Won_Reason__c == '' || opp.Differentiating_Win_Factors__c == ''|| opp.Incumbent__c == '' || opp.Competitor_s__c == ''){
                    //     helper.showToast(component,event,'Please fill in all the Closed Won Reason fields to generate a eSignature request - Primary Won Reason, Secondary Won Reason, Territory Won Reason, Differentiating Win Factors, Competitor and Incumbent.');
                    // }
                    // else{
                       helper.getAgreementTemplate(component, event);

                            // console.log('>> opp in getOppp >>',result);
                            // var urlEvent = $A.get("e.force:navigateToURL");
                            // urlEvent.setParams({
                            //     "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + component.get('v.recordId') + '&TemplateId=' + result[0].Id
                            // });
                            // urlEvent.fire();
                            // console.log('>> after fire event >>');
                            // console.log('>> result[0].Id >>',result[0].Id);

                    // }
                }
            }else{
                helper.showToast(component,event,"This User is not Permitted");
            }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, event, message) {
        console.log('>> this is toast >>');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Warning!",
            "type" : 'warning',
            "message": message
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})