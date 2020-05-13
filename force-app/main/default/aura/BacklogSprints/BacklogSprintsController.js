({
	doInit : function(component, event, helper) {
        var selectedGroup = component.get('v.selectedGroup');
		var key = component.get('v.key');
        console.log('key >>>',key);
        var map = component.get('v.agileSprint');
        console.log('The value123',map);
        console.log('value of map',map[key]);
        var sprintCaseMAp =component.get('v.agiletoCaseList');
        if(selectedGroup == 'All' || selectedGroup == '' || selectedGroup == null){
        component.set('v.sprintName',map[key].Name);
        component.set('v.caseList',sprintCaseMAp[key]);
        console.log('The case',component.get('v.caseList'));
        console.log('The case23',sprintCaseMAp[key]);
        }
        else{
            if(map[key].AssociatedGroup__c == selectedGroup){
                console.log('key',key);
                component.set('v.sprintName',map[key].Name);
                component.set('v.caseList',sprintCaseMAp[key]); 
            }
        }
    },
    changeStatus : function(component, event, helper) {
       console.log('The value',event.getSource().get("v.title"));
       var action = component.get("c.updateStatus");
       action.setParams({
        "sprintID" : event.getSource().get("v.title"),
        "name" : event.getSource().get("v.name")
    });
    action.setCallback(this, function(response) {
        console.log('Testing123');
        if (response.getState() == "SUCCESS") {
           console.log('Test>>>>>>>>>');
        }
    });
    $A.enqueueAction(action);
    },

    doView: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.target.id
        });
        editRecordEvent.fire();
    },
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    drag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },
    
    drop: function (component, event, helper) {
        event.preventDefault();
        var data = event.dataTransfer.getData("text");
        var tar = event.target;
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
        tar.appendChild(document.getElementById(data));
        console.log('value   :   ' + tar.getAttribute('data-Pick-Val'));
        console.log('data   :   ' + data);

        document.getElementById(data).style.backgroundColor = "#ffb75d";
        helper.updatePickVal(component,data,'AgileStatus__c',tar.getAttribute('data-Pick-Val'));
    }
})