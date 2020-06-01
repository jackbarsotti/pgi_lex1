({
	rerender: function(component,helper) {
       
    },
    afterRender: function (component, helper) {
        this.superAfterRender();
        component.set('v.selectedFolder','00D290000001JXXEA2');
        helper.getFolders(component);
       /* window.setTimeout(
            $A.getCallback(function() {
                helper.getAllUser(component, helper); 
            }), 4000
        ); */
        
    },
})