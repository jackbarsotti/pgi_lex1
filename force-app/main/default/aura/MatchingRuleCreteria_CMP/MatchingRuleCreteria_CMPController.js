({
	doInit : function(cmp, evt, help) {
		
		let MatchingRuleCriteria = cmp.get('v.childRuleCreteria');

		MatchingRuleCriteria.Line_Number__c = cmp.get('v.lineNumber')+1;
        cmp.set('v.childRuleCreteria',MatchingRuleCriteria);
        // let fields =  cmp.get("v.relatedFieldsinChildCMP");
        // console.log('>>>>>>>>relatedFieldsinChildCMP:doInit:: ',fields);

        // if(fields != undefined && fields != '' && fields != null && fields.length > 0){
        //     console.log('11>>>> ');
        //     // Added to get field name before change of fields
        //     if(MatchingRuleCriteria.Field_API_Name__c == undefined || 
        //         MatchingRuleCriteria.Field_API_Name__c == null || MatchingRuleCriteria.Field_API_Name__c == '' ){
        //         console.log('22>>>> ');
        //         cmp.set('v.childRuleCreteria.Field_API_Name__c',fields[0].fieldLabel);
        //         console.log('Set fieldType for Record>>>>>>> ',fields[0].fieldType)
        //         help.selectOperator(cmp, evt, fields[0].fieldType);
        //     }            
        //     //console.log('v.fields fieldType',fields[0].fieldType)
        // }

	},

	selectedFieldType : function(cmp, evt, help) {

        let val = evt.getSource().get("v.value");
        let selectedField = cmp.get("v.relatedFields").find(field => 
                                                     val === field.fieldApiName); 
        // To set Field Type to MatchingRule Creatiria Record
        let objCriteria = cmp.get('v.childRuleCreteria');
        objCriteria.Field_Type__c = selectedField.fieldType;
        cmp.set('v.childRuleCreteria',objCriteria);

        help.selectOperator(cmp,evt, selectedField.fieldType);
        cmp.set('v.fieldType',selectedField.fieldType);
    },

    ChangeHandler : function(cmp, evt, help) {
        let fields = cmp.get('v.relatedFields');
        // console.log('>>>>>>>>fields::: ',JSON.parse(JSON.stringify(fields)));
        // help.selectOperator(cmp,evt, fields[0].fieldType);
        // console.log('Field_Type__c>>>>>>>> ',cmp.get('v.childRuleCreteria.Field_Type__c'));
        help.selectOperator(cmp,evt, cmp.get('v.childRuleCreteria.Field_Type__c'));
    },

    clearRow: function(cmp,evt,help){
        let index = evt.currentTarget.id;
        let rules = cmp.get('v.MatchingRuleCreteria');
        rules.splice(index,1);
        let count = 1;
        rules.forEach(function(ele){
            ele.Line_Number__c = count;
            count = count + 1;
        });
        cmp.set('v.MatchingRuleCreteria',rules);

        // Store removed Row MR record Id
        var getRemovedrecordId = cmp.getEvent("getRemovedrecordId");
        getRemovedrecordId.setParams({ "removedrowrecordId" : cmp.get("v.childRuleCreteria.Id") });
        getRemovedrecordId.fire();
    },
})