({
	doInit : function(component, event, helper) {
		var item =[{
            		"label": '--None--',"value": ''},
                   {"label": 'Case',  "value": 'Case'},
                   {"label": 'FinReq',  "value": 'FinReq'}];
        component.set("v.options", item);
	},
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        alert("Option selected with value: '" + selectedOptionValue + "'");
    }
})