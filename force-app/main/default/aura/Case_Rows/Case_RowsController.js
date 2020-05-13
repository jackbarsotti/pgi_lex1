({
	doInit: function(cmp, evt, help) {
        //console.log('sObj OTE>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.ote_rule"))));
        console.log('isNew>>>>> ',cmp.get("v.isNew"));
        let ote_rule = cmp.get('v.ote_rule');
        ote_rule.Line_Number__c = cmp.get('v.lineNumber')+1;
        cmp.set('v.ote_rule',ote_rule);
        //console.log('ote_row>>>>>> ',JSON.parse(JSON.stringify(cmp.get("v.ote_rule.Field_Value__c"))));
       

    },

    onSelectOfObject: function(cmp, evt, help){
        console.log('isNew>onSelectOfObject>>>> ',cmp.get("v.isNew"));
		help.getRelatedFields(cmp, cmp.get("v.ote_rule.Object_Name__c"));
	},
    
    selectedFieldType : function(cmp, evt, help) {

        let val = evt.getSource().get("v.value");
        let selectedField = cmp.get("v.relatedFields").find(field => 
                                                     val === field.fieldApiName); 

        // To set Field Type to MatchingRule Creatiria Record
        let oteObj = cmp.get("v.ote_rule");
        // console.log('selectedField>>>>>>> ',selectedField);
        oteObj.Field_Type__c = selectedField.fieldType;
        cmp.set('v.ote_rule',oteObj);

        help.selectOperator(cmp,evt, selectedField.fieldType);
        cmp.set('v.fieldType',selectedField.fieldType);
        cmp.set("v.ote_rule.Field_Label__c",selectedField.fieldLabel);
    },

    clearRow: function(cmp,evt,help){
        let index = evt.currentTarget.id;
        //console.log('index>>>>> ',index);
        let rules = cmp.get('v.OppyTeamRule');
        rules.splice(index,1);
        let count = 1;
        rules.forEach(function(ele){
            ele.Line_Number__c = count;
            count = count + 1;
        });
        cmp.set('v.OppyTeamRule',rules);
        
        //console.log('OT id rule>>>>>>>>>>> ',cmp.get("v.ote_rule.Id"));
        // Store removed Row MR record Id
        var getRemovedrecordId = cmp.getEvent("getRemovedOTRule_evt");
        getRemovedrecordId.setParams({ "removedOTRuleId" : cmp.get("v.ote_rule.Id") });
        getRemovedrecordId.fire();
    },

    ChangeHandler : function(cmp, evt, help) {
        let fields = cmp.get('v.relatedFields');
        //console.log('fields>>>>> ',fields);
        // console.log('isNew>>>>> ',cmp.get("v.isNew"));
        if(cmp.get("v.isNew")){
            cmp.set("v.ote_rule.Field_Name__c",fields[0].fieldApiName);
            cmp.set("v.ote_rule.Field_Type__c",fields[0].fieldType);
            cmp.set("v.ote_rule.Field_Label__c",fields[0].fieldLabel);
        }
        help.selectOperator(cmp,evt, cmp.get('v.ote_rule.Field_Type__c'));
    },
    
})