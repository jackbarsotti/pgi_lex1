({
    doInit : function(cmp, event, helper) {
        console.log('1111111111111111');
        helper.displayFieldData(cmp);        
    },
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        helper.doSearch(cmp);        
    },
    
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp, event);
    },

    handleClick: function(cmp, event, helper) {
        helper.handlerClick(cmp, event);
    }
})