({
    deleteAllContentDoc : function(component,event,helper) {
       var action = component.get('c.delListcontentDocument');
         console.log('Deleted1');
        var alldocRec = component.get('v.attachMentRec');
        var idList =[];
        for(var key in alldocRec){
            idList.push(alldocRec[key].Id);
        }
        action.setParams({
            recordIds : idList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 console.log('Deleted');
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();  
            }
            
        })
       $A.enqueueAction(action);  
        
    },
    getAllUser : function(component, helper) {
        var action = component.get("c.getUser");
        action.setBackground ();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({label: result[key].Name, value: result[key].Email});
                }
                component.set('v.allUserList',arrayMapKeys);
            }
           
        })
        
        $A.enqueueAction(action);
        
    },
    
    getRecord : function(component, event, helper) {
        var action = component.get("c.getrecord");
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setBackground ();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let record = response.getReturnValue();
                console.log('>> record >>',record);
                /*let slecteRecord = {
                  	SObjectLabel :  record.Name,
                    SObjectId : record.Id
                };
                 component.set ('v.selectedSobjRecord', {
                    SObjectLabel :  record.Name,
                    SObjectId : record.Id
                });
                */
                var str1 = "Reply :";
                var str2 = record.Subject__c;
                var res = str1+str2;
                component.set('v.subject',res);
                component.set("v.recordDetail", response.getReturnValue());
                //Always set to fin req 
                component.set('v.originalRecordId',record.Id);
                component.find ('sObjectLookup').setValue ({
                    SObjectLabel :  record.Name,
                    SObjectId : record.Id
                });
                if(record.RequestorsEmail__c === record.Requested_For__c){
                    component.set('v.defaultSelectedAddTo',record.Requested_For__c)
                    component.set('v.selectedMulAddTo',component.get('v.defaultSelectedAddTo')+';');
                }else{
                    var defaultSelectedAddTo ='';
                    if(record.Requested_For__c != null && record.Requested_For__c != '' && record.Requested_For__c != 'undefined'){
                        defaultSelectedAddTo = record.Requested_For__c;
                    }
                    if(record.RequestorsEmail__c != null && record.RequestorsEmail__c != '' && record.RequestorsEmail__c != 'undefined'){
                        defaultSelectedAddTo += ';'+record.RequestorsEmail__c;
                    }
                    component.set('v.defaultSelectedAddTo',defaultSelectedAddTo)
                    component.set('v.selectedMulAddTo',component.get('v.defaultSelectedAddTo')+';');
                }
            }
            
        })
        
        $A.enqueueAction(action);
        
    },
    getFromAddess : function(component, event, helper) {
        var action = component.get("c.getEmailfromAdd");
        let selectedemail = component.get ('v.fromEmail');
        action.setBackground ();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: result[key], isSelected: selectedemail === result[key]});
                }
                component.set("v.options", arrayMapKeys);
            }
            
        })
        
        $A.enqueueAction(action);
        
    },
    getSobjToRelatedList : function(component, event, helper) {
        var action = component.get("c.getObjectName");
        let selectedSobjValue = component.get ('v.selectedSobjValue');
        action.setParams ({
            'selectedApiName' : selectedSobjValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var result = JSON.parse(response.getReturnValue());
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key], isSelected: selectedSobjValue === key});
                }
                component.set("v.optionsSobj",arrayMapKeys);*/
                component.set("v.optionsSobj",JSON.parse(response.getReturnValue()));
            }
            
        })
        
        $A.enqueueAction(action);
        
    },
    sendHelper: function(component, getSubject, getbody,relatedToRecord,addTo,bcc,cc,toAddress,fromEmail,relatedToObject) {
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            relatedToRecord: relatedToRecord,
            addTo: addTo,
            cc: cc,
            bcc: bcc,
            toAddress: toAddress,
            fromEmail: fromEmail,
            relatedToObject: relatedToObject,
            mSubject: getSubject,
            mbody: getbody,
            parentRecord:component.get('v.originalRecordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
               this.showToast(component,event,"Success!","Success","The Email has been Sent Successfully");
            }
            
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('Error 0',errors);
                var message = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                        var splitedMessage = message.substring(message.indexOf(',')+1);
                        //splitedMessage = splitedMessage.split(":")[0]+":"+splitedMessage.split(":")[1];
                        message = splitedMessage;
                    }
                } else {
                    message = 'Unknown error';
                }
                this.showToast(component,event,"Error!","Error",message); 
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
            parentId: component.get("v.originalRecordId"),
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
        var action = component.get("c.getContentDoc");
        action.setParams({
            recordId: component.get("v.originalRecordId")
        });    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.attachMentRec',response.getReturnValue());    
                
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
    getTemplateMergeFields : function(component,attId) {  
        var relatedToRecord = component.get("v.selectedSobjRecord.SObjectId");
        var toAddress = component.get("v.selectedRecord.SObjectId");
        var action = component.get("c.getTempletemergeData"); 
        action.setParams({
            emailTempId :component.get('v.selectedEmailTemplate'),
            toaddressId :toAddress,
            mergeFieldObjId : relatedToRecord
        }); 
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                console.log('the value is'+response.getReturnValue().subject);
                console.log('the value is1'+response.getReturnValue().emailBody);
                component.set("v.body", response.getReturnValue().emailBody);
       		   component.set("v.subject", response.getReturnValue().subject);
                
            }  
        });  
        $A.enqueueAction(action);  
    },  
    getTemplete : function(component) { 
        
        var action = component.get("c.getEmailTemplateList"); 
        action.setParams({
            "folderId":component.get('v.selectedFolder')
        }); 
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                component.set('v.listOfEmailTeplates',response.getReturnValue());
            }  
        });  
        $A.enqueueAction(action);  
    },  
    
    getFolders: function (component) {
        var selectedFolder = component.get('v.selectedFolder');
        console.log('selectedFod',selectedFolder);
        var action = component.get("c.getFolders");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key], isSelected: selectedFolder === key});
                }
                component.set("v.folderList", arrayMapKeys);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    showToast : function(component, event,title,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
        if(message.includes("Sent Succ")){
             var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        }
       
    }
})