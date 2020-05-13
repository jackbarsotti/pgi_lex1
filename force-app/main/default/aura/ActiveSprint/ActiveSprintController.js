({
    doInit : function(component, event, helper) {
        console.log('local',localStorage.getItem('Group'));
        if(localStorage.getItem('Group') != null){
            component.set('v.groupSelected',localStorage.getItem('Group'));
            console.log('local',component.get('v.groupSelected'));
        }
        // RT-559 Get Field and order
        var field;
        var order;
        if(localStorage.getItem('BacklogSort') != null){
            
            var fieldToSort = localStorage.getItem('BacklogSort');
            var NameWithorder = fieldToSort.split(".");
            if(NameWithorder[0] == 'CaseNumber'){
                field = 'Precision__c';
            }
            else if(NameWithorder[0] == 'AssignedTo'){
                field = 'Assigned_To__r.Name';
            }
            else if(NameWithorder[0] == 'EpicName'){
                field = 'AgileEpic__r.Name';
            }
            else if(NameWithorder[0] == 'Tester'){
                field = 'AgileTester__r.Name';
            }
           
            if(NameWithorder[1] == 'true'){
             order = true;   
            }
            else{
              order = false;   
            }
            console.log('Fields>>>>',field);
            console.log('Fieldsorde>>>>',order);
        }
        else{
            field ='Precision__c';
            order =true;
        }
        component.set('v.fieldToSort',field);
        component.set('v.fieldOrder',order);
        console.log('Testingww',component.get('v.fieldToSort'));
        console.log('Testing123ds',component.get('v.fieldOrder'));
        // End Field and Order
        helper.getgroupPicklist(component, event, helper);
        helper.getActiveAgileSprint(component, event, helper,component.get('v.fieldToSort'),component.get('v.fieldOrder'));
        // helper.getAllSprint(component, event, helper);
        if(!component.get('v.isForBackLog')){
            console.log('Demo');
            helper.getStatusRelatedTogroup(component, event, helper);
        }
        else{
            helper.checkGroupActive(component, event, helper);
            //to disable the complete and cancel button
            helper.getSprintStatus(component, event, helper);
        }
        console.log('Testingww123',component.get('v.fieldToSort'));
        console.log('Testing123ds123',component.get('v.fieldOrder'));
    },
    
    doView: function(component, event, helper) {
        /*console.log('000000000>',event.target.id);
// var editRecordEvent = $A.get("e.force:navigateToSObject");
// editRecordEvent.setParams({
// "recordId": event.target.id
// });
// editRecordEvent.fire();
var sfId = event.target.id;
console.log('The opening Id',sfId);
var navEvt = $A.get("e.force:navigateToSObject");

console.log('000000000>',navEvt);
if(navEvt != null)
{
navEvt.setParams({
"recordId": sfId,
"slideDevName": "detail"
});
navEvt.fire();
}else
{
// if(sforce.console.isInConsole()){
// let url= window.location.origin+'/'+sfId;
// sforce.console.openPrimaryTab(null, url ,true);
// }else{
//window.location.href = '/'+sfId;
let url= window.location.origin+'/'+sfId;
var win = window.open(url, '_blank');
win.focus();
// }
}*/
    var sfId = event.target.id;
    if(sforce.console.isInConsole()){
        console.log('The opening Id',sfId);
        let url= window.location.origin+'/'+sfId;
        console.log('The Value',url);
        // sforce.one.navigateToSObject(sfId);
        // sforce.console.openPrimaryTab(undefined, "/"+sfId ,true); tis also works
        sforce.console.openPrimaryTab(null, url ,true);
    }
    else{
        
        let url= window.location.origin+'/'+sfId;
        var win = window.open(url, '_blank');
        win.focus();
    }
},
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    drag: function (component, event, helper) {
        console.log('The id is', event.target.id);
        console.log('The Parent Node Id',event.target.parentNode.id);
        component.set('v.storeAgileName',event.target.parentNode.id)
        event.dataTransfer.setData("text", event.target.id);
    },
    
    drop: function (component, event, helper) {
        
        var tar = event.target;
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
        // console.log('value : ' + tar.getAttribute('data-Pick-Val'));
        //Draging in same sprint and for All BacklogCases.
        if((component.get('v.storeAgileName') == tar.getAttribute('data-Pick-Val')) || (component.get('v.storeAgileName') == '' && tar.getAttribute('data-Pick-Val') == null) ){
            console.log('The Vallllll123',tar.getAttribute('data-Pick-Val'));
            var data = event.dataTransfer.getData("text");
                
            // Find the record ID by crawling up the DOM hierarchy
            var tar = event.target.closest('[id]');
             console.log('The data',data);  
             console.log('Event .Target',event.target);
             var contactData;
             //to count the listSize if one no need to update pression
             var count = 0;
            console.log('The PickliStVal',tar.getAttribute('data-Pick-Val'));
             
                contactData = component.get('v.kanbanData.records');
            
            console.log('Test123',contactData);
            var index1, index2, temp; 
            // Find the index of each item to move
            contactData.forEach((v,i)=>{if(v.Id===data) index1 = i; if(v.Id===tar.id) index2 = i;});
            console.log('index1',index1);  
            console.log('index2',index2);  
            // if we place to last in active Sprint
            if(index2 == undefined){
                event.preventDefault();
                var data = event.dataTransfer.getData("text");
                var tar = event.target;
                while(tar.tagName != 'ul' && tar.tagName != 'UL')
                    tar = tar.parentElement;
                //tar.appendChild(document.getElementById(data));
                console.log('value   :   ' + tar.getAttribute('data-Pick-Val'));
                console.log('data   :   ' + data);
                //check if index2 is undefined and the list is one then we should not show spinner
                    var listrec = component.get("v.kanbanData.records");
                    //if list contains 5 records and then if we pull it again to down in same ul we should not do anything.
                    var position = 0;
                    for(var key in listrec){
                        if(component.get("v.isForBackLog")){
                            if(listrec[key].AgileSprint__c == component.get('v.storeAgileName')){
                                count = count + 1;
                                if(listrec[key].Id == data){
                                    position =count; 
                                }
                                
                            }    
                        }
                        else{
                            
                            if(listrec[key].AgileStatus__c == component.get('v.storeAgileName')){
                                count = count + 1;
                                if(listrec[key].Id == data){
                                    position =count; 
                                }
                                
                            } 
                        }
                    }
                //end
                console.log('COUNT',count);
                console.log('position',position);
                if(count != position){
                    helper.setPrecision(component,component.get("v.kanbanData.records"),data,component.get('v.storeAgileName'),event,helper,index2,count);
                }
                console.log('Sprint to Sprint: ',component.get("v.kanbanData.records")); 
            }
            else{
                if(index1<index2) {
                    console.log('The Vallllll');
                    // Lower index to higher index; we move the lower index first, then remove it.
                    contactData.splice(index2+1, 0, contactData[index1]);
                    contactData.splice(index1, 1);
                    
                
                } else {
                    console.log('The Vallllll1');
                    // Higher index to lower index; we remove the higher index, then add it to the lower index.
                    temp = contactData.splice(index1, 1)[0];
                    contactData.splice(index2, 0, temp);
                    
                }
                //only for Backlog Cases data-Pick-Val is null and storeAgileName(ie Parent Name is null)
               
                    // Trigger aura:valueChange, component will rerender
                    component.set("v.kanbanData.records", contactData);
                
                console.log('COUNT',count);
                console.log('The Valueof kanban',component.get("v.kanbanData.records"));   
                event.preventDefault();
                helper.setPrecision(component,contactData,data,component.get('v.storeAgileName'),event,helper,index2,count);
            }
        }
        //moving to different Sprint.
        else{
            event.preventDefault();
        var data = event.dataTransfer.getData("text");
        var tar = event.target;
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
        //tar.appendChild(document.getElementById(data));
        console.log('value   :   ' + tar.getAttribute('data-Pick-Val'));
        console.log('data   :   ' + data);

        document.getElementById(data).style.backgroundColor = "#ffb75d";
        var isForBackLog = component.get("v.isForBackLog");
        helper.showSpinner( component );
        if(isForBackLog){
            helper.updatePickVal(component,data,'AgileSprint__c',tar.getAttribute('data-Pick-Val'),helper);
        }else{
            helper.updatePickVal(component,data,'AgileStatus__c',tar.getAttribute('data-Pick-Val'),helper);
        }
        console.log('Sprint to Sprint: ',component.get("v.kanbanData.records")); 
        }
        
       /* if(toprecord.Precision__c == undefined && bottomRecord.Precision__c == undefined){
            precisionToUpdate = 0;
        }
        else if(toprecord.Precision__c == undefined && bottomRecord.Precision__c != undefined){
            precisionToUpdate =  (Math.random() * (0 - toprecord.Precision__c) + toprecord.Precision__c);
        }
        console.log('The Random',(Math.random() * (bottomRecord.Precision__c - toprecord.Precision__c) + toprecord.Precision__c));*/
       /* document.getElementById(data).style.backgroundColor = "#ffb75d";
        var isForBackLog = component.get("v.isForBackLog");
        
        if(isForBackLog){
            helper.updatePickVal(component,data,'AgileSprint__c',tar.getAttribute('data-Pick-Val'));
        }else{
            helper.updatePickVal(component,data,'AgileStatus__c',tar.getAttribute('data-Pick-Val'));
        }*/
        
    },
    // RT-559
    handleClickorder : function(component, event, helper) {
        var columnName = event.currentTarget.title; 
        var clickedTitle1 = event.currentTarget.id; 
        console.log('The Value',columnName);
        var isAsc;
        console.log('The Value',clickedTitle1);
        var preLocalValue = localStorage.getItem('BacklogSort');
        // var field;
        var fieldName;
        var order = true;
        if(columnName == 'CaseNumber'){
            fieldName = 'Precision__c';
        }
        else if(columnName == 'AssignedTo'){
            fieldName = 'Assigned_To__r.Name';
        }
        else if(columnName == 'EpicName'){
            fieldName = 'AgileEpic__r.Name';
        }
        else if(columnName == 'Tester'){
            fieldName = 'AgileTester__r.Name';
        }
        if(preLocalValue != null){
            var localVal = preLocalValue.split(".");
            console.log('The Value',localVal[0]);
            console.log('The Value1',localVal[1]);
            if(localVal[0] == columnName){
                if(localVal[1] == 'true'){
                    console.log('Hai');
                    order = false;
                }
            }
            localStorage.removeItem('BacklogSort');
            // isAsc = true;
        }
        
        //  let columnName = event.getSource().get("v.name"); 
        // console.log('StartsWith123'+localStorage.getItem('BacklogSort'));
        // var fieldName;
        // if(columnName == 'CaseNumber'){
        //     fieldName = 'Precision__c';
        // }
        // else if(columnName == 'AssignedTo'){
        //     fieldName = 'Assigned_To__r.Name';
        // }
        // else if(columnName == 'EpicName'){
        //     fieldName = 'AgileEpic__r.Name';
        // }
        // else if(columnName == 'Tester'){
        //     fieldName = 'AgileTester__r.Name';
        // }
        // let selectedGroup1 = event.getSource().get("v.title"); 
        // let selectedGroup2 = event.getSource().get("v.iconName"); 
        console.log('order'+order);
        window.localStorage.setItem('BacklogSort', columnName+'.'+order);
        console.log('StartsWith'+localStorage.getItem('BacklogSort'));
        helper.getActiveAgileSprint(component, event, helper,fieldName,order);
        // helper.doInitHelper(component, event, helper);
         component.set('v.fieldToSort',fieldName);
         component.set('v.fieldOrder',order);
    },
    onSelectChange : function(component, event, helper) {
        let selectedGroup = event.getSource().get("v.value");
        window.localStorage.setItem('Group', selectedGroup);
        console.log('The storage',localStorage.getItem('Group'));
        component.set('v.groupSelected',selectedGroup);
        helper.getActiveAgileSprint(component, event, helper,component.get('v.fieldToSort'),component.get('v.fieldOrder')).then(
            $A.getCallback(function(result){
                if(!component.get('v.isForBackLog')){
                    var map = component.get('v.groupToAgileStatus');
                    console.log('Mapvalues1',map[component.get('v.groupSelected')]);
                    component.set('v.kanbanData.pickVals',map[component.get('v.groupSelected')]);
                    console.log('the picklist1',component.get('v.kanbanData.pickVals'));
                }
                else{
                    helper.checkGroupActive(component, event, helper);
                    helper.getSprintStatus(component, event, helper);
                }
            })
        )
       
},
    changeStatus : function(component, event, helper) {
        helper.showSpinner(component);
        helper.setAgileStatus(component, event, helper).then(
            $A.getCallback(function(result){
                helper.checkGroupActive(component, event, helper);
                helper.getActiveAgileSprint(component, event, helper,component.get('v.fieldToSort'),component.get('v.fieldOrder')).then(
                    $A.getCallback(function(result){
                            helper.hideSpinner( component );
                    })
                )
            })
        )
        /* helper.setAgileStatus(component, event, helper).then(
$A.getCallback(function(result){
if(result == false && event.getSource().get("v.label") == 'Start'){
console.log('The resul123t',result);
// var modelId = component.find("modelId");
// $A.util.addClass(modelId , 'slds-show');
// $A.util.removeClass(modelId , 'slds-hide');
alert("There is already a Active Sprint");
}

else{
if(event.getSource().get("v.label") == 'Start'){
event.getSource().set("v.disabled",true);
}
else{
event.getSource().set("v.disabled",true);
}
}
})
)
var String = event.getSource().get("v.title")+event.getSource().get("v.label");
// component.find("String").set("v.disabled", false);
// console.log('Hai');*/
},
    
    openPopUp : function(component, event, helper) {
        console.log('The popupId',event.getSource().get("v.value"));
        component.set('v.caseRecordId',event.getSource().get("v.value"));
        let url = window.location.hostname;
        let param = '/apex/ClassicChatterFeed?id='+component.get('v.caseRecordId');
        let finalURl = 'https://'+url+param;
        component.set('v.vfHost',finalURl);
        console.log('The Url is',component.get('v.vfHost'));
        
        var modelId = component.find("modelId");
        $A.util.addClass(modelId , 'slds-show');
        $A.util.removeClass(modelId , 'slds-hide');
        
        
        
        //var recordId = component.get("v.recordId");
        // var url = '/apex/ClassicChatterFeed';
        // // var urlEvent = $A.get("e.force:navigateToURL");
        // // urlEvent.setParams({
        // // "url": url
        // // });
        // // urlEvent.fire();
        // window.open(url, '_self','width=500,height=500');
        console.log('The recId',component.get('v.caseRecordId'));
        
    },
    handleCloseModel : function(component, event, helper) {
        var modelId = component.find("modelId");
        $A.util.addClass(modelId , 'slds-hide');
        $A.util.removeClass(modelId , 'slds-show');
        console.log('The id is',event.target.getAttribute("id"));
        
    }
})