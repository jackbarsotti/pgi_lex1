({
	doInit : function(component, event, helper) {
        console.log('recordId=>',component.get('v.recordId'));
		var item =[{"label": '--None--',"value": ''},
                   {"label": 'Case',  "value": 'Case'},
                   {"label": 'FinReq',  "value": 'Financial_Request__c'}];
        component.set("v.options", item);
	},
    handleTypeChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedType", selectedOptionValue);
        var caseRecordType = [{"label": 'Internal Support',"value":'Internal Support'},
                              {"label": 'Client External Support',  "value": 'Client External Support'},
                              {"label": 'Reservations Request',  "value": 'Reservations Request'},
                              {"label": 'Parent Ticket (NOC)',  "value": 'Parent Ticket (NOC)'}];
        
        var finReqRecordType = [{"label": 'Billing Support',  "value": 'Billing Support'},
                                {"label": 'Company Credit',  "value": 'Company Credit'},
                                {"label": 'Payment Research Request',  "value": 'Payment Research Request'},
                                {"label": 'Credit Request',  "value": 'Credit Request'},
                                {"label": 'Pricing Help Request',  "value": 'Pricing Help Request'},
                                {"label": 'Profile Request',  "value": 'Profile Request'},
                                {"label": 'Request for Adjustment',  "value": 'Request for Adjustment'},
                                {"label": 'Revenue Assurance Audit Request',  "value": 'Revenue Assurance Audit Request'},
                              	{"label": 'Rate Entry Request',  "value": 'Rate Entry Request'}];
        if(selectedOptionValue == 'Case'){
            component.set("v.recordType", caseRecordType);
        }
        if(selectedOptionValue == 'Financial_Request__c'){
            component.set("v.recordType", finReqRecordType);
        }
    },
    handleRecordTypeChange : function(component, event){
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedRecordType", selectedOptionValue);
        component.set("v.isDisabled", false);
    },
    escalateEmailCase : function(component, event, helper){
        helper.escalateEmailCase(component, event,helper);
    }
})