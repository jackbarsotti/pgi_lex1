({
    doInit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var action = component.get("c.getStatus");
        action.setParams({
            "recordId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var title = '';
            var type = '' ;
            var message = '';
            if (state === "SUCCESS") {
                var status = response.getReturnValue();
                if(status == 'Qualifying'){
                    var id = component.get('v.recordId');
                    window.location = '/lead/leadconvert.jsp?retURL=%2F'+id+'&id='+id;
                }
                
                else{
                        title = 'Warning!';
                        type = 'warning';
                        message = 'In order to Convert, your Lead Status must be set to Qualifying';
                  helper.showToast(component, event,title,type,message);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        title = 'Error';
                        type = 'error';
                        message =  errors[0].message;
                        helper.showToast(component, event,title,type,message);
                    }
                } else {
                        title = 'Error';
                        type = 'error';
                        message = 'Unknown error';
                        helper.showToast(component, event,title,type,message);
                }
            }
        })
        $A.enqueueAction(action);
    }
})