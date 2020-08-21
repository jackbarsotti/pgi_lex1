( {
    init : function( component, event, helper ) {

        helper.fetchRecords(component, event, helper);
        helper.getAgileStatusbyGroup(component, event, helper);
       // helper.getAgileNameTogroup(component, event, helper);

    },    
    applySortable : function( component, event, helper ) {        
        var sortableApplied = component.get( "v.sortableApplied" );
        var scriptsLoaded 	= component.get( "v.scriptsLoaded" );
        
        console.log('sortableApplied: ',sortableApplied);
        console.log('scriptsLoaded: ',scriptsLoaded);

        /**
         * Apply the jQuery Sortable
         * when the DOM is ready and 
         * the Scripts have been loaded.
         */
        if( scriptsLoaded 	&& 
           !sortableApplied && 
           jQuery( ".slds-lane" ).length > 0
		) {
            component.set( "v.sortableApplied", true );
            
            helper.applySortable( component );
        }
    },
    logACall : function( component, event, helper ) {
        var createRecordEvent = $A.get( "e.force:createRecord" );
        
        createRecordEvent.setParams(
            {
                "entityApiName" 	: "Task",
                "defaultFieldValues": {
                    "WhoId" 	: event.getSource().get( "v.name" ),
                    "Subject" 	: "Log A Call"
                }
            }
        );
        
        createRecordEvent.fire();
    },
    logAMeeting : function( component, event, helper ) {
        var createRecordEvent = $A.get( "e.force:createRecord" );
        
        createRecordEvent.setParams(
            {
                "entityApiName" 	: "Event",
                "defaultFieldValues": {
                    "WhoId" 	: event.getSource().get( "v.name" ),
                    "Subject" 	: "Log A Meeting"
                }
            }
        );
        
        createRecordEvent.fire();
    },
    onGroupChange : function( component, event, helper ) {
        helper.getRecordsbySelectedGroup( component, event, helper );
    },
    openChaterModel : function(component, event, helper) {
        
        var caseId = event.getSource().get("v.value");
        let url = window.location.hostname; 
        let param = '/apex/ClassicChatterFeed?id='+caseId;
        let finalURl = 'https://'+url+param;
        component.set('v.vfHost',finalURl);

        var chatterId = component.find("chatterId"); 
        $A.util.addClass(chatterId , 'slds-show');
        $A.util.removeClass(chatterId , 'slds-hide');       
    },
    handleCloseChatterModel : function(component, event, helper) {
        var chatterId = component.find("chatterId"); 
                $A.util.addClass(chatterId , 'slds-hide');
                $A.util.removeClass(chatterId , 'slds-show');
                console.log('The id is',event.target.getAttribute("id"));
                
    }
} )