({
    getFromAddess : function(component, event, helper) {
        var action = component.get("c.getEmailfromAdd");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.options", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(action);
        
    },
    getSobjToRelatedList : function(component, event, helper) {
        var action = component.get("c.getObjectName");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.optionsSobj", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(action);
        
    },
    sendHelper: function(component, getEmail, getSubject, getbody) {
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.mailStatus", true);
            }
 
        });
        $A.enqueueAction(action);
    },
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
 
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
 
        objFileReader.readAsDataURL(file);
    },
 
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
 
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.attachParentId"),
            //parentId: 'a8E29000000GqnGEAS',
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    alert('your File is uploaded successfully'+attachId);
                    component.set("v.showLoadingSpinner", false);
                    this.getContentDoc(component,event,helper);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    getContentDoc: function(component,event,helper){
        var recordId = component.get('v.recordId');
		  var action = component.get("c.getContentDoc");
        action.setParams({
            recordId: component.get("v.attachParentId")
        });    
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.attachMentRec',response.getReturnValue());    
                alert("Option selected with value: '" + component.get('v.attachMentRec') + "'");
            }  
        });
         $A.enqueueAction(action);
    },
    delUploadedfiles : function(component,attId) {  
        var action = component.get("c.delcontentDocument");           
        action.setParams({
            "recordId":attId            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                this.getContentDoc(component,event,helper);
            }  
        });  
        $A.enqueueAction(action);  
    },  
    getBaseUrl : function(component,attId) {  
        var action = component.get("c.baseUrl");    
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                component.set('v.baseUrl',response.getReturnValue());
            }  
        });  
        $A.enqueueAction(action);  
    },  
     //get email templates
    getAllEmailTemplateValues : function(component, event){
        var action = component.get("c.getEmailTemplateValuesIntoPickList");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var response = response.getReturnValue();   
                if(response.length>0){
                    component.set("v.listOfEmailTeplates",response); 
                }
                else{
                    component.set("v.listOfEmailTeplates",'');
                }
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);      
    },
})