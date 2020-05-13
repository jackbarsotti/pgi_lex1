({
    doInit : function(component) {
        // hide the component after 6 sec
        setTimeout(function(){ component.destroy(); }, 6000);
    },
    closetoastMessage : function(component) {
        // hide the component 
       component.destroy();
    },
})