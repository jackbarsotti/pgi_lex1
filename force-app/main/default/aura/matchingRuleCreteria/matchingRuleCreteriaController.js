({
    doInit : function(cmp, evt, help) {

        // console.log('v.MatchingRuleCreation>>chuld doInit>>>> ',cmp.get("v.MatchingRuleCreation"));
        
        console.log('fields<>>>>>>>>>>>> ',cmp.get("v.fields"));

        let MatchingRuleCriteria = cmp.get('v.childObject');
        if(cmp.get("v.setOutput") || cmp.get("v.isEdit")){
                cmp.set('v.FieldType',MatchingRuleCriteria.Field_Type__c);
            }

        MatchingRuleCriteria.Line_Number__c = cmp.get('v.lineNumber')+1;
        cmp.set('v.childObject',MatchingRuleCriteria);
        let fields =  cmp.get("v.fields");
        if(fields != undefined && fields != '' && fields != null && fields.length > 0){
            // Added to get field name before change of fields
            if(MatchingRuleCriteria.Field_API_Name__c == undefined || 
                MatchingRuleCriteria.Field_API_Name__c == null || MatchingRuleCriteria.Field_API_Name__c == '' ){
                cmp.set('v.childObject.Field_API_Name__c',fields[0].fieldLabel);
                help.selectOperator(cmp, evt, fields[0].fieldType);
            }            
            //console.log('v.fields fieldType',fields[0].fieldType)
        }
        
    },
    selectedFieldType : function(cmp, evt, help) {
        // cmp.set('v.childObject.Field_Value__c','');
        let val = evt.getSource().get("v.value");
        let selectedField = cmp.get("v.fields").find(field => 
                                                     val === field.fieldApiName); 
        let objCriteria = cmp.get('v.childObject');
        objCriteria.Field_Type__c = selectedField.fieldType;
        cmp.set('v.childObject',objCriteria);
        help.selectOperator(cmp,evt, selectedField.fieldType);
        //console.log('>>>>>>>>',selectedField.fieldType);
        cmp.set('v.FieldType',selectedField.fieldType);
    },
    removeValue : function(cmp, evt, help) {
        // onchange of field name removing value 
        cmp.set("v.childObject.Field_Value__c",'');

    },

    ChangeHandler : function(cmp, evt, help) {

        let fields = cmp.get('v.fields');
        //console.log('fields>>>>>>>>> ',fields);
        help.selectOperator(cmp,evt, fields[0].fieldType);
    },
    clearRow: function(cmp,evt,help){
        let index = evt.currentTarget.id;
        //console.log('index>>>>>>>>>>>>> ',cmp.get("v.childObject.Id"));

        let rules = cmp.get('v.MatchingRuleCreation');
        // console.log('index0--->'+index);
        // console.log(rules);
        
        rules.splice(index,1);
        let count = 1;
        rules.forEach(function(ele){
            ele.Line_Number__c = count;
            count = count + 1;
        });
        //console.log(rules);
        
        cmp.set('v.MatchingRuleCreation',rules);

        
        var getRemovedrecordId = cmp.getEvent("getRemovedrecordId");

        getRemovedrecordId.setParams({ "removedrowrecordId" : cmp.get("v.childObject.Id") });
        getRemovedrecordId.fire();
        
        // Look up event by name, not by type
        /*var compEvent = cmp.getEvent("ClearMatchingRow");
        console.log(compEvent);
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        compEvent.setParams({"indexOfRow" :index});
        compEvent.fire();*/
    },
    removeMatchingRow :function(cmp, evt, help){
        
        
    },
})