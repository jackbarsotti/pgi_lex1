({
    getCreatedRecords: function(cmp, evt){
        let action = cmp.get('c.getOTERecords');
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(res.getReturnValue());
                console.log('res current records>>>> ',res);
                cmp.set("v.OTMember",res.oteMember);
                cmp.set("v.OppyTeamRule",res.oteRule);
            }
        });
        $A.enqueueAction(action);
    },

    // check null values
    isNotNull : function(value){
        return  value != undefined &&  value != null && value != '' ? true : false;
    },

    saveRecords : function(cmp, evt, help) {
        var message;

        var spinner = cmp.find('initSpinner');
        $A.util.removeClass(spinner, "slds-hide");

        let OTMember = cmp.get('v.OTMember');
        let OppyTeamRule = cmp.get('v.OppyTeamRule');
	
        // console.log('OTMember>>>> ',JSON.parse(JSON.stringify(OTMember)));
        // console.log('OppyTeamRule>>>> ',JSON.parse(JSON.stringify(OppyTeamRule)));

        let action = cmp.get("c.saveOppyTeamEngineRecords");
        action.setParams({
            "OTMember" : JSON.stringify(OTMember),
            "oppyTeamRule" : JSON.stringify(OppyTeamRule),
            "removedOTRuleIds": cmp.get("v.removedOTRuleIds"),
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var returnObj = JSON.parse(res.getReturnValue());
                if(cmp.get("v.isNew")){
                    this.showToastMessage(cmp, 'Record Inserted Successfully', "SUCCESS");
                    // redirect in same tab
                    window.location.href = "/"+returnObj.oteMember.Id;
                } 
                if(cmp.get("v.isEdit")){
                    this.showToastMessage(cmp, 'Record Updated Successfully', "SUCCESS");
                }
                cmp.set("v.isNew",false);
                
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