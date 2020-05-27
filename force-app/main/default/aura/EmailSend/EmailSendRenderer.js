({
	rerender: function(component,helper) {
       
    },
    afterRender: function (component, helper) {
        this.superAfterRender();
        component.set('v.selectedFolder','00D290000001JXXEA2');
        helper.getFolders(component);
        helper.getAllUser(component, helper); 
    },
})