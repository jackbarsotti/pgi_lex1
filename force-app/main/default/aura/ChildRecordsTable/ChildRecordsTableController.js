({
	handleEditRecord : function(cmp, evt, help) {
		
		// var spinner = cmp.find('initSpinner');
  //       $A.util.removeClass(spinner, "slds-hide");  

        var modelId = cmp.find("modelId"); 
        $A.util.addClass(modelId , 'slds-show');
        $A.util.removeClass(modelId , 'slds-hide');

        var action = cmp.get("c.getMatchingRuleCreteria");
        action.setParams({
            "recordId" : cmp.get("v.MatchingRuleRecord.Id")
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                help.editChildMatchingRule(cmp, evt, res.getReturnValue());
            }
            // $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);

	},

	handleDeleteRecord : function(cmp, evt, help) {
		
		if(confirm('Do you want to DELETE '+cmp.get("v.MatchingRuleRecord.Name")+' record?')){

            var spinner = cmp.find('initSpinner');
            $A.util.removeClass(spinner, "slds-hide");
            
            let recordId = cmp.get("v.MatchingRuleRecord.Id");
            let getRelatedMRlist = [];
            let message;

        	let action = cmp.get('c.deleteRecord');            
            action.setParams({
                "recordId" :  recordId
            });
            action.setCallback(this, function(res){
                if(res.getState()){

                    let deleteMRrow = evt.target.getAttribute("id");
                    getRelatedMRlist = JSON.parse(JSON.stringify(cmp.get("v.RelatedMatchingRuleRecords")));
                    for(var i = 0; i < getRelatedMRlist.length; i++){
                        if(getRelatedMRlist[i].Id == deleteMRrow){
                            getRelatedMRlist.splice(i, 1);
                            break;
                        }  
                    }
                    cmp.set("v.RelatedMatchingRuleRecords", getRelatedMRlist);

                    message = "Record DELETED successfully";
                    // help.showToastMessage(cmp, message, "SUCCESS");
                }
                $A.util.addClass(spinner, "slds-hide");
            });

            $A.enqueueAction(action);
        }

	},

	handleRedirect: function(cmp, evt, help){
		// redirect to new tab
        window.open("/" + cmp.get('v.MatchingRuleRecord.Id'));
	},

	handleCloseModel: function(cmp, evt, help){
    	var modelId = cmp.find("modelId"); 
        $A.util.addClass(modelId , 'slds-hide');
        $A.util.removeClass(modelId , 'slds-show');
    }

})