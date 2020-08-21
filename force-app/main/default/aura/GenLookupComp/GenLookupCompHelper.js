({
	init : function(component, event, helper) {
		
	},
    clear : function (component, event, helper) {
        this.toggleItem (component, event, 'lookup-pill', false);
        this.toggleItem (component, event, 'lookupField', true);
        this.toggleItem (component, event, 'lookupFieldSearchIcon', true);
        component.set ('v.searchKey', '');
        component.set ('v.searchMessage', 'Search Result ');
        component.set ('v.selectedRecordId', '');
        this.clearLookUpResult (component); 
        this.fireApplicationEvent (component, event, false, '', '');
            
    },
    search : function (component, event, helper) {
        let searchString = component.get ('v.searchKey');
        
        component.set ('v.searchMessage', 'Search Result for ' + searchString);
        if (searchString.length > 1) {
             this.toggleSearchResult (component, false);
             this.doSearch (component, event, searchString);
        } else {
             this.toggleSearchResult (component, true);
        }
    },
    
    doSearch : function  (component, event, searchKey) {
        component.set ('v.lookupResult', null);
        
        let action = component.get ('c.lookup');
        action.setParams ({
            "searchString" : searchKey,
            "sObjectAPIName" : component.get ('v.sObjectAPIName'),
            "fld_API_Text" : component.get ('v.field_API_text'),
			"fld_API_Val" : component.get ('v.field_API_val'),
            "fld_API_Search" :component.get ('v.field_API_search'),
            "limitVal" : component.get ('v.limit'),
            "isSOQL" : component.get ('v.isSOQL'),
            "filter" : ''
        });
        let self = this;
        action.setCallback (this, function (response) {
            let state = response.getState ();
            
            //console.log ('Response state :' + state);
            //console.log ('Response return value :' + response.getReturnValue ());
            if (state === 'SUCCESS') {
                let result = response.getReturnValue ();
                if (result && result.length > 0) {
                    component.set ('v.lookupResult', result);
                } else {
                   self.clearLookUpResult (component);
                }
            } else if (state === 'ERROR') {
                console.log ('Error :' + response.getError ());
                self.clearLookUpResult (component);
            } else {
               	console.log ('INCOMPLETE :' + response.getError ());
               	self.clearLookUpResult (component);
            }
        });
        $A.enqueueAction (action);
    },
    
    clearLookUpResult : function (component) {
        component.set ('v.searchMessage', 'No results found');
        component.set ('v.lookupResult', null);
        component.set ('v.selectedRecord', null);
    },
    
    
    handleItemSelected : function (component, event) {
    	let selectedRecord = event.getParam ('selectedItem');
        if (selectedRecord) {
         	component.set ('v.selectedRecord', selectedRecord);
            component.set ('v.selectedRecordId', selectedRecord.SObjectId);
            
            this.toggleItem (component, event, 'lookup-pill', true);
            this.toggleItem (component, event, 'lookupField', false);
            this.toggleItem (component, event, 'lookupFieldSearchIcon', false);
            this.toggleSearchResult (component, true);
            
            this.fireApplicationEvent (component, event, true, selectedRecord.SObjectId, selectedRecord.SObjectLabel);
            
            
        }
        
    },
    setSelection : function (component, selectedItem) {
        component.set ('v.selectedRecord', selectedItem);
        component.set ('v.selectedRecordId', selectedItem.SObjectId);
        this.toggleItem (component, event, 'lookup-pill', true);
        this.toggleItem (component, event, 'lookupField', false);
        this.toggleItem (component, event, 'lookupFieldSearchIcon', false);
        this.toggleSearchResult (component, true);
    },
    fireApplicationEvent : function (component, event, isItemSelected, itemId, itemLabel) {
      	    let updateEvent = $A.get("e.c:GenLookupEvent");
            updateEvent.setParams({"SObjectId": itemId, 
                                   "SObjectLabel": itemLabel,
                                   "isSelected" : isItemSelected});
            updateEvent.fire(); 
    },
    toggleSpinner : function (component, event, shouldShow) {
        let spinner = component.find ('spinner');
        let spinnerEvent = spinner.get ('e.toggle');
        spinnerEvent.setParams ({isVisible : shouldShow});
        spinnerEvent.fire ();
    },
    toggleItem : function (component, event, itemId, shouldShow) {
        let item = component.find (itemId);
        $A.util.addClass (item, shouldShow ? 'slds-show' : 'slds-hide');
        $A.util.removeClass (item, shouldShow ? 'slds-hide' : 'slds-show');
    }, 
    
    toggleSearchResult : function (component, isCloseFirst) {
    	let forOpen = component.find("searchRes");
        if (isCloseFirst) {
            $A.util.addClass(forOpen, 'slds-is-close');
            $A.util.removeClass(forOpen, 'slds-is-open');
        } else {
        	$A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close'); 
        }
	}
})