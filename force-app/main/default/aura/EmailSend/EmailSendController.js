({
    doInit : function(component, event, helper) {
         helper.getSobjToRelatedList(component, event, helper);  
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var userIe = $A.get("$SObjectType.CurrentUser.Email");
        component.set('v.defaultSelectedBcc',userIe);
        component.set('v.selectedMulBcc',component.get('v.defaultSelectedBcc'));
        component.set('v.selectedSobjValue','Financial_Request__c');
      
        component.set('v.fromEmail','noreplylesforcecrmsupport@pgi.com');
        // Task
        //helper.getAllUser(component, event, helper); 
            
        helper.getRecord(component, event, helper);
        helper.getFromAddess(component, event, helper);
        
      
    },
    // Task
    handleMulAddClick : function(component, event, helper) {
        component.set('v.selectMultiple',true);
        component.set('v.purpose','addTo');
        component.find("multiSelect").set('v.value',component.get('v.defaultAddToforDuel'));
    },
    handleMulCCClick : function(component, event, helper) {
        component.set('v.selectMultiple',true);
        component.set('v.purpose','cc');
        component.find("multiSelect").set('v.value',component.get('v.defaultCCforDuel'));
    },
     handleMulBccClick : function(component, event, helper) {
        component.set('v.selectMultiple',true);
        component.set('v.purpose','bcc');
        component.find("multiSelect").set('v.value',component.get('v.defaultBccforDuel'));
    },
    handleMulSel : function(component, event, helper) {
        var purpose = component.get('v.purpose');
        var selectedOptionValue = event.getParam("value");
        var selectedOptionValueString = selectedOptionValue.toString();
        var selectedList = [];
        if(selectedOptionValueString !== null && selectedOptionValueString !== undefined && selectedOptionValueString !== '' ){
            selectedList = selectedOptionValueString.split(",");
        }
            
        component.set('v.duelSelectedList',selectedList);
       /* if(allAddTo.includes(",")){
            allAddTo = allAddTo.replace(/,/g,";");
        }*/
        //component.set('v.selectedMulAddTo',allAddTo);
        //console.log('The value is',component.get('v.selectedMulAddTo'));
    },
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var fromEmail = component.get("v.fromEmail");
        if(fromEmail.includes(">")){
         fromEmail = fromEmail.substring(fromEmail.indexOf('<')+1,fromEmail.indexOf('>'));
        }
        alert('the from add'+fromEmail);
        var toAddress = component.get("v.selectedRecord.SObjectId");
        var cc = component.get("v.selectedMulcc");
        var bcc = component.get("v.selectedMulBcc");
        var addTo = component.get("v.selectedMulAddTo")
        var relatedToRecord = component.get("v.selectedSobjRecord.SObjectId");
        var relatedToObject = component.get("v.selectedSobjValue");
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(toAddress)) {
            alert('Please Select valid To Address');
        } 
        else if($A.util.isEmpty(getSubject))
        {
           alert('Please Enter Subject'); 
        }
        else {
            helper.sendHelper(component, getSubject, getbody,relatedToRecord,addTo,bcc,cc,toAddress,fromEmail,relatedToObject);
        }
    },
    
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
  
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            component.set('v.showButton',true);
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selected = component.find('fromAdd').get('v.value');
        /*if(selected.includes(">")){
         selected = selected.substring(selected.indexOf('<')+1,selected.indexOf('>'));
        }*/
        component.set('v.fromEmail',selected);
        console.log('The Value is',component.get('v.fromEmail'));
    },
    handleSobjChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selected = component.find('onjId').get('v.value');
        component.find ('sObjectLookup').clear(); 
        component.set('v.selectedSobjValue',selected);
    },
    previewFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        }); 
        /*var documentId = event.currentTarget.id;
        window.open('/'+documentId);*/
      /* var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": documentId,
      "slideDevName": "related"
    });
    navEvt.fire(); */
    },  
    
    delFiles:function(component,event,helper){
        var documentId = event.currentTarget.id; 
        helper.delUploadedfiles(component,documentId);
    }, 
    getTempleteId:function(component,event,helper){
        var emailTempId = event.currentTarget.id;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.selectedEmailTemplate", emailTempId);
        /*if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.listOfEmailTeplates");
            emailTemplateList.forEach(function (element) {
                if (element.Id == emailTempId ) {
                    if(element.HtmlValue  != null && element.HtmlValue  != ''){
                     emailbody = element.HtmlValue;   
                    }
                    else if(element.Body != null && element.Body != ''){
                      emailbody = element.Body;  
                    }
                    emailSubject = element.Subject;
                }
            });
        }
        component.set("v.body", emailbody);
        component.set("v.subject", emailSubject);*/
        helper.getTemplateMergeFields(component,event,helper);
        component.set('v.isModalOpen',false);
        alert('The Value'+emailTempId);
    }, 
   selectTemplete:function(component,event,helper){
       var toadd = component.get("v.selectedRecord.SObjectId");
       var relatedToRecord = component.get("v.selectedSobjRecord.SObjectId");
       if(toadd == null || toadd == '' || toadd == 'undefined'){
          helper.showToast(component,event,"Warning!","Warning","Please select To address"); 
       }
       else if(relatedToRecord == null || relatedToRecord == '' || relatedToRecord == 'undefined'){
           helper.showToast(component,event,"Warning!","Warning","Please select Relate To record"); 
       }
           else{
               //in doinit loading template takes time so using this only for the first time
               if(component.get('v.isGetFirstTempTemplete')){
                   component.set('v.isGetFirstTempTemplete',false)
                   helper.getTemplete(component);
               }	
               component.set('v.isModalOpen',true);  
           }
    }, 
    handleFolderChange : function(component,event,helper){
        var folderId = component.find('folderId').get('v.value');
        component.set("v.selectedFolder",folderId);
        if(folderId != 'undefined' && folderId != null && folderId != ''){
            helper.getTemplete(component,event,helper);
        }
        
    }, 
    closeModel:function(component,event,helper){
        component.set('v.isModalOpen',false);
    },
    closeMultipleModel:function(component,event,helper){
        var purpose = component.get('v.purpose');
        var listofSelected = component.get('v.duelSelectedList');
        var stringValue =listofSelected.join(";");
        if(purpose === 'addTo'){
            component.set('v.defaultAddToforDuel',component.get('v.duelSelectedList'));
            stringValue = component.get('v.defaultSelectedAddTo')+';'+stringValue;
            component.set('v.selectedMulAddTo',stringValue);
        }
        else if(purpose === 'cc'){
            component.set('v.defaultCCforDuel',component.get('v.duelSelectedList'));
            component.set('v.selectedMulcc',stringValue);
        }
        else{
            component.set('v.defaultBccforDuel',component.get('v.duelSelectedList'));
            stringValue = component.get('v.defaultSelectedBcc')+';'+stringValue;
            component.set('v.selectedMulBcc',stringValue);
        }
        component.set('v.selectMultiple',false);
    },
     closequickAction:function(component,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})