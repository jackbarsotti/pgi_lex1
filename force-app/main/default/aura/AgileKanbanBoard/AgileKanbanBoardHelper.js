({
    fetchRecords : function( component, event, helper ) {

        var action = component.get( "c.initialize" );
        
        component.set( "v.scriptsLoaded", true );
        
        action.setCallback( this, function( response ) {
            var state = response.getState();
            
            if ( state === "SUCCESS" ) {
                var result = response.getReturnValue();
                component.set("v.initialRecords",result);
                
                console.log('result: ',result);

                // this.getRecordsbySelectedGroup(component, event, helper);

                var cols = {};
                result.columns.forEach(
                    function( col ) {
                        cols[col.label] = col;
                    }
                );

                var rows = [];               
                for( var key in result.rows ) {
                    rows.push( { value: result.rows[key], key: cols[key] } );
                }
                
                console.log('rows: ',rows);
                console.log('columns: ',result.columns);

                component.set( "v.rows", rows );                
                component.set( "v.columns", result.columns );
                
                helper.hideSpinner( component );
            }
            else {
                // helper.showToast( 
                //     {
                //         "title"		: "Error", 
                //         "message"	: "Error: " + JSON.stringify( response.getError() ) + ", State: " + state, 
                //         "isSuccess"	: "error"
                //     } 
                // );

                var message = "Error: " + JSON.stringify( response.getError() ) + ", State: " + state;
                this.showToastMessage(component, message, "ERROR");
            }
        } );
        
        $A.enqueueAction( action );

    },
    getRecordsbySelectedGroup : function(  component, event, helper  ){
        var selectedGroupName = component.get("v.selectedGroupName");
        var initialRecords = component.get("v.initialRecords");

        console.log('selectedGroupName: ',selectedGroupName);

        var initialColumns = initialRecords.columns;
        var initialRows = initialRecords.rows;
        var agileStatusbyGroupName = component.get("v.agileStatusbyGroupName");
        console.log('The Value',agileStatusbyGroupName);
        var agileStatuscolumnstoDisplay = agileStatusbyGroupName[selectedGroupName];

        var filteredColumns = [];
        initialColumns.forEach(element => {
            if(agileStatuscolumnstoDisplay.includes((element.label).trim())){
                filteredColumns.push(element);
            }
        })
        console.log('filteredColumns',filteredColumns);
        var cols = {};
        filteredColumns.forEach(
            function( col ) {
                cols[col.label] = col;
            }
        );

        var filteredRows = [];
        agileStatuscolumnstoDisplay.forEach(col => {
            var filteredRow = initialRows[col];
            console.log('filteredRow. : ',filteredRow);
            console.log('filteredRow AgileSprint__r. : ',filteredRow.AgileSprint__r);
            console.log('filteredRow.AgileSprint__r.AssociatedGroup__c: ',filteredRow.AgileSprint__r.AssociatedGroup__c);
            if(selectedGroupName == filteredRow.AgileSprint__r.AssociatedGroup__c){
                filteredRows.push( { value: filteredRow, key: cols[col] } );
            }
            
        })
        
        console.log('Filtered rows : ',filteredRows);
        console.log('Filtered columns: ',filteredColumns);

        component.set( "v.rows", filteredRows );                
        component.set( "v.columns", filteredColumns );
    },
    //For Backlog
    /*getAgileNameTogroup : function( component, event, helper ) {

        var action = component.get("c.getAgileNamebyAssociatedGroup");
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set('v.agileStatusbyGroupName',response.getReturnValue());
                var agileStatusbyGroupName = component.get("v.agileStatusbyGroupName");
                const associatedGroups = Object.keys(agileStatusbyGroupName);
                component.set('v.associatedGroupList',associatedGroups);
                console.log('The groupList',component.get('v.associatedGroupList'));
            }
        });
        $A.enqueueAction(action);

    },*/

    getAgileStatusbyGroup : function( component, event, helper ) {

        var action = component.get("c.getAgileStatusbyAssociatedGroup");
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set('v.agileStatusbyGroupName',response.getReturnValue());
                var agileStatusbyGroupName = component.get("v.agileStatusbyGroupName");
                const associatedGroups = Object.keys(agileStatusbyGroupName);
                component.set('v.associatedGroupList',associatedGroups);
                console.log('The value', component.get('v.associatedGroupList'));
            }
        });
        $A.enqueueAction(action);

    },
    hideSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.addClass( eleSpinner, "slds-hide" );
    },
    showSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.removeClass( eleSpinner, "slds-hide" );
    },
    showToast : function( data ) {
        var toastEvent = $A.get( "e.force:showToast" );
                                
        toastEvent.setParams(
            {
                duration	: 2000,
                title		: data.title,
                message		: data.message,
                type		: data.type ? data.type : (data.isSuccess ? "success" : "error")
            }
        );
        
        toastEvent.fire();
    },
    applySortable : function( component ) {     
        var helper = this;
        
       	jQuery( ".slds-lane" ).sortable(
            {
                revert				: true,
                connectWith			: ".slds-lane",
                handle 				: ".slds-title",
                placeholder 		: "slds-item slds-m-around--small slds-item-placeholder"
            }
		);
        
        jQuery( ".slds-lane" ).on(
            "sortstart",
            $A.getCallback(
                function( event, ui ) {                    
                    jQuery( ui.item ).addClass( "moving-card" );
                }
            )
        );
        
		jQuery( ".slds-lane" ).on(
            "sortstop",
            $A.getCallback(
                function( event, ui ) {                    
                    jQuery( ui.item ).removeClass( "moving-card" );                    
                    
                    var caseId       		= $( ui.item ).data( "id" );
                    var oldLeadStatus 		= $( ui.item ).data( "status" );
                    var newLeadStatus   	= $( ui.item ).parent().data( "name" );
                    var isDropEnabled 		= $( ui.item ).parent().data( "drop-enabled" );
                    
                    console.log('Updating caseId: ',caseId);
                        console.log('Updating oldLeadStatus: ',oldLeadStatus);
                        console.log('Updating newLeadStatus: ',newLeadStatus);
                        console.log('Updating isDropEnabled: ',isDropEnabled);

                    /**
                     * If the cards were dropped
                     * into a prohibited column
                     * and if the action was not
                     * just a re-ordering then
                     * thrown an error!
                     */
                    if( !isDropEnabled && oldLeadStatus !== newLeadStatus ) {
                        jQuery( ".slds-lane" ).sortable( "cancel" );
                        
                      /*  helper.showToast( {
                            isSuccess 	: false,
                            title 		: "Prohibited",
                            message 	: "You cannot move cards into this column. Action has been reverted."
						} );*/
                    }
                    else {
                    	helper.showSpinner( component );
                        
                        var action = component.get( "c.updateCaseKanbanOrder" );
                        var params = {
                            "caseId" 		: caseId,
                            "newLeadStatus" : newLeadStatus,
                            "ordering" 		: []
                        };
                        
                        /**
                         * Maintain the ordering within
                         * the lane.
                         */
                        $( ui.item ).parent().children().each(
                            function() {
                                params.ordering.push( $( this ).data( "id" ) );
                            }
                        );
                        
                        action.setParams( params );
                        
                        action.setCallback( 
                            this, 
                            function( response ) {
                                var state = response.getState();
                                
                                console.log('state: ',state);
                                helper.hideSpinner( component );
                                

                                if( state === "SUCCESS" ) {                                    
                                    var updateStatus = response.getReturnValue();
                                    console.log('updateStatus: ',updateStatus);
                                    /**
                                     * Show a separate message
                                     * if the cards were just
                                     * re-arranged within the
                                     * same column.
                                     */                                    
                                    if( oldLeadStatus === newLeadStatus ) {
                                        updateStatus.type 		= "info";
                                        updateStatus.message	= "Column Ordering was Updated.";
                                    }
                                    
                                    $( ui.item ).attr( "data-status", newLeadStatus );
                                    
                                    //helper.showToast( updateStatus );
                                    this.showToastMessage(component, 'Column Ordering was Updated.', "SUCCESS");
                                }
                            }
                        );
                        
                        $A.enqueueAction( action );
                    }
                }
            )
        );
    },
    // toast message display
    showToastMessage : function(component , message, messageType){
        $A.createComponent(
            "c:ClassicToastMessage",
            { 
                "message" : message,
                "messageType" : messageType
            },
            function(newInp, status, errorMessage){
                
                if (status === "SUCCESS") {
                    var container = cmp.find("toastMessageBody");
                    let body = [];
                    body.push(newInp);
                    container.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("incomplete: " + errorMessage);
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }, 
})