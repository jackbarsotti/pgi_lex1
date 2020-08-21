({
    closeMethodInAuraController: function (component, event, helper) {
        console.log(component.get("v.recordId"));
        $A.get("e.force:closeQuickAction").fire();


    },
    saveMethodController: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Success!',
            duration: 10000,
            mode: 'dismissible',
            type: 'success',
            message: 'Opportunity created',
            messageTemplate: 'Record {0} created! See it {1}!',
            messageTemplateData: ['Salesforce', {
                url: '/lightning/r/Opportunity/' + event.getParam('value') + '/view',

                label: 'click to visit opportunity page',
            }
            ]
        });
        toastEvent.fire();


        console.log('swapnil', event.getParam('value'));
        $A.get("e.force:closeQuickAction").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();


    }




})