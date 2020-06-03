import { LightningElement, api,wire,track } from 'lwc';
import getFromAdress from '@salesforce/apex/SendAnEmailComposer.getFromAdress';
import getEmailSLA from '@salesforce/apex/SendAnEmailComposer.getEmailSLA';
import generatePreview from '@salesforce/apex/SendAnEmailComposer.generatePreview';
import getTemplates from '@salesforce/apex/SendAnEmailComposer.getTemplates';
import getEmailFolders from '@salesforce/apex/SendAnEmailComposer.getEmailFolders';
import sendAnMail from '@salesforce/apex/SendAnEmailComposer.sendAnMail';

export default class SendAnEmail extends LightningElement {
    @api recordId;
    @api fromAdressList;
    @api subject;
    @api mailBody;
    @api origin;
    @api template;
    @track isDisabled = true;
    @track isModalOpen = false;
    @track templateList;
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
    sendEmail(){
        if(this.toReceipientIds.length > 0){
            sendAnMail({templateId : this.templateId, recId : this.recordId, toRecepients : this.toReceipientIds, bccRecepients : this.bccReceipientIds, ccRecepients : this.ccReceipientIds})
            .then(result=>{
                const closeQA = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeQA);
            })
            .catch(error => {
                this.error = error;
            });

        }else{
            const event = new ShowToastEvent({
                title: 'No Receipeints',
                message: 'Add Receipeints.',
            });
            this.dispatchEvent(event);
        }
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
    
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
}