({
	init : function(component, event, helper) {
		helper.init (component, event, helper);
	},
    clear : function (component, event, helper) {
        helper.clear (component, event, helper);
    },
    search : function (component, event, helper) {
        helper.search (component, event, helper);
    },
    showSpinner : function (component, event, helper) {
        helper.toggleSpinner (component, event, true);
    },
    hideSpinner : function (component, event, helper) {
        helper.toggleSpinner (component, event, false);
    },
    handleItemSelected : function (component, event, helper) {
        helper.handleItemSelected (component, event);
    },
    handleVFEvent : function (component, event, helper) {
        console.log ('VF Event fired');
    }
})