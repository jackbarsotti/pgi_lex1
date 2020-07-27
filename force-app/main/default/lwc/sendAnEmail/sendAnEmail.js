import { LightningElement, api,wire,track } from 'lwc';
import getFromAdress from '@salesforce/apex/SendAnEmailComposer.getFromAdress';
import getEmailSLA from '@salesforce/apex/SendAnEmailComposer.getEmailSLA';
import generatePreview from '@salesforce/apex/SendAnEmailComposer.generatePreview';
import getTemplates from '@salesforce/apex/SendAnEmailComposer.getTemplates';
import getEmailFolders from '@salesforce/apex/SendAnEmailComposer.getEmailFolders';

const columns = [
    {
        label: 'Attatchment Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    }];

export default class SendAnEmail extends LightningElement {
    @api recordId;
    @api fromAdressList;
    @api subject;
    @api mailBody;
    @api origin;
    @api template;
    @track attachmentName=[];
    @track isDisabled = true;
    @track isModalOpen = false;
    @track templateList;
    @track data=[];
    @track keyIndex = 0;
    @track columns = columns;
    @api emailFolders;
    value = 'new';
    

    get options() {
        return [
            { label: 'None', value: '' },
            { label: 'Closed', value: 'closed' },
            { label: 'New', value: 'new' },
            { label: 'Customer Replied', value: 'customerReplied' },
            { label: 'New', value: 'new' },
            { label: 'Pending Client Info/Action', value: 'pendingClientAction' },
            { label: 'New-Transferred', value: 'newTransferred' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Pending Internal Replay', value: 'pendingInternalReplay'}];
    }
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }
    @wire(getEmailFolders,{})
    folderOptions({data,error}){
        if(data){
            let folders = [];
            data.forEach(key=>{
                folders.push({
                    label:key.Name,
                    value:key.Id
                });
            });
            this.emailFolders = folders;
        }
        else if(error){
            console.log(error);
        }
    }
    @wire(getFromAdress,{})
    fromAdresses({data,error}){
            if(data){
            let fromAdress = [];
            data.forEach(key=>{
                console.log('====>',key);
                fromAdress.push({
                    label:key.DisplayName,
                    value:key.Address
                });
            });
            this.fromAdressList = fromAdress;
        }
        else if(error){
            console.log(error);
        }
    }
  handleChange(event){
        var fromMailAddress = event.detail.value;
        this.isDisabled = false;
        getEmailSLA({emailAddress: fromMailAddress})
            .then(result => {
                console.log('===>', result);
                this.template = result.Email_Template__c;
                this.origin = result.Origin__c;
                generatePreview({templateName: result.Email_Template__c, recId : this.recordId})
                    .then(result => {
                        console.log('===>', result);
                        this.subject = result.Subject;
                        this.mailBody = result.HtmlValue;
                    })
                    .catch(error => {
                        console.log('===>', error);
                        this.error = error;
                    });
            })
            .catch(error => {
                this.error = error;
            });
        
    }
    handleTemplates(){
        this.isModalOpen = true;
    }
    handleFolderChange(event){ 
        getTemplates({folderId:event.detail.value})
        .then(result=>{
            this.templateList = result;
        })
        // recipient({data,error}){
        //     if(data){
        //         var templateRecordList = [];
        //         data.forEach(key=>{
        //             templateRecordList.push({
        //                 Id= key.Id,
        //                 name = key.Name,
        //                 developerName = key.DeveloperName
        //             });
        //             this.templateList = templates;
        //         })
        //     }else if(error){
        //         console.log(error);
        //     }
        // }

    }
    handleTemplate(event){
        this.isModalOpen = false;
        this.template = event.target.name
        generatePreview({templateName: event.target.value, recId : this.recordId})
        .then(result => {
            this.subject = result.Subject;
            console.log('result.HtmlValue====>',result.HtmlValue);
            if(result.HtmlValue == null && result.HtmlValue == undefined){
                this.mailBody = '';
            }else{
                this.mailBody = result.HtmlValue;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    
    handleUploadFinished(event) {
        // Get the list of uploaded files
        var uploadedFiles = event.detail.files;
        console.log('uploadedFiles>>',uploadedFiles);
        this.attachmentName=uploadedFiles;
        console.log('uploadattach>>',this.attachmentName);
        let uploadedFileNames = '';
       
        for(let i = 0; i < uploadedFiles.length; i++) {
            this.keyIndex++;
            console.log('index>>',this.keyIndex);
            uploadedFileNames += uploadedFiles[i].name + ', ';
           
        }
      //  this.dispatchEvent();
      console.log('uploadedFileNames>>',uploadedFileNames);
     // this.data=this.attachmentName;
    //  console.log('data>>',this.data);
     // this.connectedCallback();
    }
    handleDelete(event){
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.id;
    console.log('key>>',key);
    var allFiles=[];
     allFiles=this.attachmentName;
      console.log('attachmentName>>',this.attachmentName);
      console.log('allFiles<<',allFiles);
      for(let i=0;i<allFiles.length;i++){
          if(i==key){
              console.log('i>>',i);
              allFiles.splice(key, 1);
              console.log('all>>',allFiles.splice(key, 1));
              this.keyIndex--;
          }
        //  this.attachmentName=allFiles[i].name;
       //   console.log('newFiles>>',allFiles[i].name);

      }
      this.attachmentName=allFiles;
      console.log('newFiles>>',allFiles.name);
     

    }

    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
}