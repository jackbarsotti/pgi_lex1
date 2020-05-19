({
    doInit : function(component, event, helper) {
        var recordid= component.get('v.recordId');
        component.set('v.attachParentId',recordid);
        component.set('v.subject','Reply');
        helper.getBaseUrl(component, event, helper);
        helper.getFromAddess(component, event, helper);
        helper.getSobjToRelatedList(component, event, helper);
        
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
		component.set('v.email',percent);
        alert("Option selected with value: '" + percent + "'");
    },
    handleSobjChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var percent = component.find('onjId').get('v.value');
        alert("Option selected with value: '" + percent + "'");
    },
    previewFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        }); 
        var documentId = event.currentTarget.id;
        window.open('/'+documentId);
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
   
     changeTemplate: function(component, event, helper) {
        var etVal = event.getSource().get("v.value");
        component.set("v.storeEmailTemplate",etVal);
        //get email template body 
        helper.getAllEmailTemplateValues(component, event);
    },
})