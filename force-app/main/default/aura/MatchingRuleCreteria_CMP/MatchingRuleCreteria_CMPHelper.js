({
	selectOperator: function(cmp, evt, val){

        if(val =='STRING' || val =='PICKLIST'){
            var operValue = [
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterOrEqual", label: "greaterOrEqual" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "startsWith", label: "startsWith" }
            ];
            cmp.set('v.operatorType',operValue);
            
        }else if(val == 'BOOLEAN'){
            //console.log('testt');
            var operValue = [ 
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" }
            ];
            cmp.set('v.operatorType',operValue);
            
        }else if(val == 'DATE' || val == 'CURRENCY' || val == 'DATETIME' || val == 'DATETIME' ||
                 val == 'INTEGER' || val == 'PERCENT' || val == 'AUTONUMBER' ||  val == 'DOUBLE'){
            
            var operValue = [
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterOrEqual", label: "greaterOrEqual" }
            ];
            cmp.set('v.operatorType',operValue);
            
        }else if(val == 'REFERENCE'){
            
            var operValue = [
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" },
                { value: "startsWith", label: "startsWith" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterOrEqual", label: "greaterOrEqual" },
                { value: "includes", label: "includes" },
                { value: "excludes", label: "excludes" },
                { value: "within", label: "within" }
            ];
            cmp.set('v.operatorType',operValue);
        }else{
            var operValue = [
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" },
                { value: "startsWith", label: "startsWith" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterOrEqual", label: "greaterOrEqual" },
                { value: "includes", label: "includes" },
                { value: "excludes", label: "excludes" },
                { value: "within", label: "within" }
            ];
            cmp.set('v.operatorType',operValue);
        }
        
    },

    getRelatedFields: function(cmp, sObjectName) {
        
        var action = cmp.get("c.getALLFields");
        action.setParams({
            "objName" : sObjectName
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                let fields = res.getReturnValue();
                fields.sort((a, b) => (a.fieldLabel > b.fieldLabel) ? 1 : (a.fieldLabel === b.fieldLabel) ? ((a.fieldApiName > b.fieldApiName) ? 1 : -1) : -1 )

                for(var i=0; i < fields.length; i++){
                    if(fields[i].fieldApiName == cmp.get("v.childRuleCreteria.Field_API_Name__c")){
                        cmp.set("v.FieldValue",fields[i].fieldLabel);
                        break;
                    }
                }
            }
            return ;
        });
        $A.enqueueAction(action);

    },

    
})