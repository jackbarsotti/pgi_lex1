({
    getFieldsofRecord : function(component, event, helper) {
        var promise = new Promise(function(resolve,reject){
            var action = component.get("c.getFields");
            action.setParams({
                "recordId": component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('state: ',state);
                if (state === "SUCCESS") {
                    resolve("true");
                    component.set('v.recordData',response.getReturnValue());
                    console.log('The Value is ',component.get('v.recordData'));
                }
                else{
                    reject("false");
                }
            });
            $A.enqueueAction(action);
        });
        return promise;
    }
})