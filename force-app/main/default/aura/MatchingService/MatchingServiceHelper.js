({
    getALLsObjects : function(cmp, evt) {
        let action = cmp.get('c.getallobjects');
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var res = res.getReturnValue();
                cmp.set('v.options',JSON.parse(res));
            }
        });        
        $A.enqueueAction(action);
    },
    startMatchingService : function(cmp, evt) {
        console.log('start matchin service');
        let action = cmp.get('c.processRecord');
        action.setParams({
            objName : cmp.get('v.selectedObject'),
            recordId : cmp.get('v.recordId')
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            console.log('state:::',state);
            if(state === 'SUCCESS'){
                var res = res.getReturnValue();
                console.log('res',res);
                let cmpType = "lightning:formattedRichText", attrs ={};
                attrs.value = res;                
                $A.createComponent(cmpType, attrs, function(newCmp, status, statusMsgLst) {
                    console.log(status); 
                    if (status === "ERROR") {
                        console.log(statusMsgLst);                    
                    }else{
                        console.log(status);  
                        if(cmp.isValid()){
                            var body = cmp.get('v.body');
                            body.push(newCmp);
                            cmp.set('v.body', body);
                        }
                    }
                }); 
                cmp.get('v.supportText',res);
                console.log('supportText>>>>>>>>> ',cmp.get("v.supportText"));
            }
        });        
        $A.enqueueAction(action);
    },
})