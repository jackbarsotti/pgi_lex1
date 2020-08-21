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
                { value: "greaterorEqual", label: "greaterorEqual" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "startwith", label: "startwith" }
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
                { value: "greaterorEqual", label: "greaterorEqual" }
            ];
            cmp.set('v.operatorType',operValue);
            
        }else if(val == 'REFERENCE'){
            
            var operValue = [
                { value: "--None--", label: "--None--" },
                { value: "equals", label: "equals" },
                { value: "notEqual", label: "notEqual" },
                { value: "startswith", label: "startswith" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterorEqual", label: "greaterorEqual" },
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
                { value: "startswith", label: "startswith" },
                { value: "contains", label: "contains" },
                { value: "doesnotcontains", label: "doesnotcontains" },
                { value: "lessThan", label: "lessThan" },
                { value: "greaterThan", label: "greaterThan" },
                { value: "lessOrEqual", label: "lessOrEqual" },
                { value: "greaterorEqual", label: "greaterorEqual" },
                { value: "includes", label: "includes" },
                { value: "excludes", label: "excludes" },
                { value: "within", label: "within" }
            ];
            cmp.set('v.operatorType',operValue);
        }
        
    },
    
})