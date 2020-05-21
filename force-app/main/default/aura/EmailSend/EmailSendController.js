({
    doInit : function(component, event, helper) {
        
        component.set('v.selectedFolder','00D290000001JXXEA2');
        component.set('v.selectedSobjValue','Financial_Request__c');
        component.set("v.storeEmailTemplate",null); 
        var recordid= component.get('v.recordId');
        component.set('v.attachParentId',recordid);
        component.set('v.subject','Reply');
        component.set('v.fromEmail','noreplylesforcecrmsupport@pgi.com');
        /*helper.getTemplete(component,event,helper);
        helper.getRecord(component, event, helper);
        helper.getFromAddess(component, event, helper);
        helper.getSobjToRelatedList(component, event, helper);
        helper.getFolders(component, event);
        helper.getUser(component, event);*/
        helper.getEmailTemplateHelper(component, event, helper);
    },
    
    
    
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody);
        }
    },
    
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
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
        var percent = component.find('fromAdd').get('v.value');
		component.set('v.fromEmail',percent);
        alert("Option selected with value: '" + percent + "'");
    },
    handleSobjChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selected = component.find('onjId').get('v.value');
        component.set('v.selectedSobjValue',selected);
        alert('the value'+selected);
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
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
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
        }emailTempId
        component.set("v.body", emailbody);
        component.set("v.subject", emailSubject);
        component.set('v.isModalOpen',false);
    }, 
   selectTemplete:function(component,event,helper){
        component.set('v.isModalOpen',true);
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
})