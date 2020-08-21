({
    getAgreementTemplate : function(component, event, helper) {
        var result;
        var actionAT = component.get("c.getAgreementTemplateData");
        actionAT.setCallback(this, function(response){
            var state = response.getState();
            console.log('state for AT: ',state);
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                    console.log('>> result in getAT >>',result); 
                    var id = component.get('v.recordId');
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        // "url": '/apex/echosign_dev1__AgreementTemplateProcess?p2_lkid='+id+'&p3_lkid='+id
                        //  "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId='+id+'&TemplateId='+result.Id+'&p3_lkid='+id
                        "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId='+id+'&TemplateId='+result.Id
                    });
                    urlEvent.fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToastMsg(component, event,title,type,message);
                    }
                } else {
                    title = 'Error';
                    type = 'error';
                    message = 'Unknown error';
                    helper.showToastMsg(component, event,title,type,message);
                }
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
            var title = '';
            var type = '' ;
            var message = '';
            console.log('state for sign Agreement: ',state);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
               console.log('>> res >>',res);
                component.set("v.SignAgreementList",res);
                console.log('=====> get SignAggr ===>',component.get("v.SignAgreementList"));
                // if(res.length >= 1){
                //     // helper.showToast(component,event,'There is already an open Adobe Agreement against this opportunity');
                //     var toastEvent = $A.get("e.force:showToast");
                //     toastEvent.setParams({
                //         "type" : 'warning',
                //         "message": "There is already an open Adobe Agreement against this opportunity."
                //     });
                //     toastEvent.fire();
                // }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToastMsg(component, event,title,type,message);
                    }
                } else {
                    title = 'Error';
                    type = 'error';
                    message = 'Unknown error';
                    helper.showToastMsg(component, event,title,type,message);
                }
            }
        });
        $A.enqueueAction(action);
    },    
    getOpportunity : function(component, event, helper) {
        var action = component.get("c.getOpportunityData");
        action.setParams({
            oppId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var title = '';
            var type = '' ;
            var message = '';
            console.log('>> state :  ',state);
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();
                component.set("v.opprtunityList",opp);
                console.log('>> opp in getOppp >>',opp);
            //    helper.getSignAgreement(component, event);
            var signAg = component.get("v.SignAgreementList");
            console.log('>> signAg >>',signAg);
            if(signAg.length >= 1){
                // helper.showToast(component,event,'There is already an open Adobe Agreement against this opportunity');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : 'warning',
                        "message": "There is already an open Adobe Agreement against this opportunity."
                    });
                    toastEvent.fire();
            } 
            else{  
               if(opp.StageName == 'Awareness'){
                    helper.showToast(component,event,'eSignature is not available for opportunities that are in the Awareness stage. Please move this opportunity beyond Awareness before using eSignature.');
                }else if(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won' ){
                    helper.showToast(component,event,'eSignature is not available for Closed opportunities.');
                }
                else{
                    console.log('>> else >>');
                    if(opp.Primary_Won_Reason__c == '' || opp.Secondary_Won_Reason__c == '' || opp.Tertiary_Won_Reason__c == '' || opp.Differentiating_Win_Factors__c == ''|| opp.Incumbent__c == '' || opp.Competitor_s__c == ''){
                        // helper.showToast(component,event,'Please fill in all the Closed Won Reason fields to generate a eSignature request - Primary Won Reason, Secondary Won Reason, Territory Won Reason, Differentiating Win Factors, Competitor and Incumbent.');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                                    "type" : 'warning',
                                    "message": "Please fill in all the Closed Won Reason fields to generate a eSignature request - Primary Won Reason, Secondary Won Reason, Territory Won Reason, Differentiating Win Factors, Competitor and Incumbent."
                                });
                        toastEvent.fire();
                    }
                    else{
                       helper.getAgreementTemplate(component, event);

                            // console.log('>> opp in getOppp >>',result);
                            // var urlEvent = $A.get("e.force:navigateToURL");
                            // urlEvent.setParams({
                            //     "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + component.get('v.recordId') + '&TemplateId=' + result[0].Id
                            // });
                            // urlEvent.fire();
                            // console.log('>> after fire event >>');
                            // console.log('>> result[0].Id >>',result[0].Id);

                    }
                }
            }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToastMsg(component, event,title,type,message);
                    }
                } else {
                    title = 'Error';
                    type = 'error';
                    message = 'Unknown error';
                    console.log('>>>>message >> ',message);
                    helper.showToastMsg(component, event,title,type,message);
                }
            }
           
        })
        $A.enqueueAction(action);
        // $A.enqueueAction(actionAT);
    },
    // getResult : function(component, event, helper) {
    //     console.log('>> result >>');
    //     var signRecordsList = component.get("v.SignAgreementList");
    //     var oppRecordsList = component.get("v.opprtunityList");
    //     console.log('>>signRecordsList >>',signRecordsList);
    //     console.log('>>signRecordsList length>>',signRecordsList.length);
    //     console.log('>>oppRecordsList >>',oppRecordsList);
    //     console.log('>>oppRecordsList length >>',oppRecordsList.length);

    // },
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
    },
    showToastMsg : function(component, event,title,type,message) {
        console.log('>> from toast >>');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
       
    }
})