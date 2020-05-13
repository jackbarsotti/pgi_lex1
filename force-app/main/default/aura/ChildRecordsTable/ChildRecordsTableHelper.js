({
	editChildMatchingRule : function(cmp, evt, relatedRecords) {
		
		var relatedMatchingCretiriaRecords = JSON.parse(JSON.stringify(relatedRecords));

		$A.createComponent(
            "c:MatchingRule_CMP", 
            {
                MatchingRule : cmp.get("v.MatchingRuleRecord"),
                isChildMRedit : true,
                MatchingRuleCreteria: relatedMatchingCretiriaRecords
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body = [];
                    body.push(newButton);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );

	}	
})