public with sharing class EmailComposer {

    public List<Attachment> attachments{get;set;} 

    public EmailComposer() {
        //fromAddbeforeChange = false; 
    }
    public class EmailComposerException extends Exception {}
    public EmailTemplate theEmailTemplate {get; set;}
    public String subject {get; set;}
    public String emailBody {get; set;}
    public String replyMailId {get;set;}
    public String toAll {get; set;}
    public Boolean initialized {get; set;}
    public Object attachedFile { get; set; }
    public Contact theContact {get {
        if(currentCase != null && currentCase.ContactId != null) {
            return new Contact(Id = currentCase.contactId);
        } else {
            List<Contact> tempContact = [SELECT Id FROM Contact WHERE Customer_User_ID__c = 'DefaultForEmail'];
            if(tempContact.size() == 0) {
                Contact c = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'test@pgi.com', Customer_User_ID__c = 'DefaultForEmail');
                insert c;
                return c;
            } else {
                return tempContact[0];
            }
        }
    } set;}
    public Boolean createdCaseOnPageLoad = false;
    public Case currentCase {get; set {
        if(currentCase != value && currentCase != null) {
            generatePreview(theEmailTemplate);
        }
        currentCase = value;
    }}
    public Boolean showForm {get; set;}

   
    
    public String fromAddress {get; set {
        fromAddress = value;
        if(String.isNotBlank(value) && emailSlaMap.get(value) != null) {
            String selectedTemplateDevName = emailSlaMap.get(value).Email_Template__c;
            origin = emailSlaMap.get(value).Origin__c;
            try {
                this.theEmailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: selectedTemplateDevName LIMIT 1];
                System.debug('The from1 Address'+ this.theEmailTemplate);
            } catch (Exception e) {
                System.debug(e);
                throw new EmailComposerException(e.getMessage());
                // origin = '';
            }
        } else {
            this.theEmailTemplate = null;
            origin = '';
    }
    }}
    public String toAddress {get; set;}
    public String origin {get; set;}
    public String f {get; set;}
    public String bccAddress {get; set;}
    public String ccAddress {get; set;}
    public String selectedTemplate {get {
        return theEmailTemplate == null ? '' : theEmailTemplate.Name;
    }}
    //used to create lookup field for case object
    public EmailMessage em {get {
        if(em == null) {
            em = new EmailMessage(ParentId = this.currentCase.Id); 
        } else {
            em.ParentId = this.currentCase.Id;
        }
        return em;
    } set;}
    public Case passedInFrom {get; set;}
    /* METHODS */
    public Pagereference composeEmail() {
        if(currentCase == null) {
            System.debug('Test12345');
            Case workingCase; //variable to prevent stack depth error
            //if passed in from a current case
            if(passedInFrom != null) {
                // Check if RecordType is "PGi Client External Support"
                if (passedInFrom.RecordTypeId != externalSupportRTId) {
                    workingCase = passedInFrom;
                }
            }
            if(workingCase == null) {
                workingCase = new Case();
                createdCaseOnPageLoad = true;
                workingCase.Status = 'New';
                workingCase.RecordTypeId = outboundCaseRTId;
                workingCase.Follow_Up_Email_Address__c = passedInFrom != null ? passedInFrom.Follow_Up_Email_Address__c : '';
                workingCase.ParentId = passedInFrom != null ? passedInFrom.Id : null;
                insert workingCase; 
            }
            this.currentCase = queryCase(workingCase.Id);
        }
        
        
        
        showForm = true;
        return null;
    }
   
    public Pagereference init() {
        //fromAddbeforeChange= false;
        initialized = false;
        try {
            if(inConsole == null) {
                inConsole = false;
            } 
            isReply = false;
            isFwd = false;
            validate();
            initialized = true;
        } catch (Exception e) {
            composeOnLoad = false;
            initialized = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    public Pagereference doNothing() {
        return null;
    }
    public class EmailRecipients {
        public List<Recipient> toList {get; set;}
        public List<Recipient> originalToList {get; set;}
        public String toListObj {get {
            return JSON.serialize(toList);
        }}
        public List<Recipient> ccList {get; set;}
        public List<Recipient> bccList {get; set;}
        public String ccAddress {get {
            String returnStr = '';
            for(Recipient r: ccList) {
                returnStr += r.email.trim() + ';';
            }
            return returnStr;
        } set;}
        
        public String originalToListString {get {
            String returnStr = '';
            for(Recipient r: originalToList) {
                String person = '';
                if(String.isNotBlank(r.displayName)) {
                    person += r.displayName.trim() + ';'; 
                }
                returnStr += person.trim();
            }
            return returnStr;
        } set;}

        public String toListString {get {
            String returnStr = '';
            for(Recipient r: toList) {
                String person = '';
                if(String.isNotBlank(r.displayName)) {
                    person += r.displayName.trim() + ';'; 
                }
                returnStr += person.trim();
            }
            return returnStr;
        } set;}
        public String ccListString {get {
            String returnStr = '';
            for(Recipient r: ccList) {
                String person = '';
                if(String.isNotBlank(r.displayName)) {
                    person += r.displayName.trim() + ';'; 
                }
                returnStr += person;
            }
            return returnStr;
        } set;}
       /* public String bccListString {get {
            String returnStr = '';
            for(Recipient r: bccList) {
                String person = '';
                if(String.isNotBlank(r.displayName)) {
                    person += r.displayName.trim() + ';'; 
                }
                returnStr += person;
            }
            return returnStr;
        } set;}*/
        public EmailRecipients(EmailMessage theEmail) {
            toList = new List<Recipient>();
            originalToList = new List<Recipient>();
            ccList = new List<Recipient>();
            bccList = new List<Recipient>();
            
            //handle address fields
            if(String.isNotBlank(theEmail.toAddress)) {
                if(theEmail.toAddress.contains(';')) {
                    for(String address: theEmail.ToAddress.split(';')) {
                        toList.add(new Recipient(address));
                        originalToList.add(new Recipient(address));
                    }
                } else {
                    toList.add(new Recipient(theEmail.ToAddress));
                    originalToList.add(new Recipient(theEmail.ToAddress));
                }
            }
            if(String.isNotBlank(theEmail.ccAddress)) {
                if(theEmail.ccAddress.contains(';')) {
                    for(String address: theEmail.ccAddress.split(';')) {
                        ccList.add(new Recipient(address));
                    }
                } else {
                    ccList.add(new Recipient(theEmail.ccAddress));
                }
            }
            if(String.isNotBlank(theEmail.bccAddress)) {
                if(theEmail.bccAddress.contains(';')) {
                    for(String address: theEmail.bccAddress.split(';')) {
                        bccList.add(new Recipient(address));
                    }
                } else {
                    bccList.add(new Recipient(theEmail.bccAddress));
                }
            }
            if(String.isNotBlank(theEmail.fromAddress)) {
                if(theEmail.fromAddress.contains(';')) {
                    for(String address: theEmail.fromAddress.split(';')) {
                        toList.add(new Recipient(address));
                    }
                } else {
                    toList.add(new Recipient(theEmail.fromAddress));
                }
            }

            //handle IDs
            Set<Id> allIDs = new Set<Id>();
            allIDs.addAll(theEmail.toIds);
            allIDs.addAll(theEmail.ccIds);
            allIDs.addAll(theEmail.bccIds);
            if(!allIds.isEmpty()){
                allIDs.remove(null);
                List<Contact> contacts = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id IN: allIds];
                for(Contact rec: contacts) {
                    if(theEmail.toIds != null && theEmail.toIds.contains(rec.Id)) {
                      toList.add(new Recipient(rec));
                    }
                    if(theEmail.ccIds != null && theEmail.ccIds.contains(rec.Id)) {
                      ccList.add(new Recipient(rec));
                    }
                    if(theEmail.bccIds != null && theEmail.bccIds.contains(rec.Id)) {
                      bccList.add(new Recipient(rec));
                    }
                }
                List<User> users = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id IN: allIds];
                for(User rec: users) {
                    if(theEmail.toIds != null && theEmail.toIds.contains(rec.Id)) {
                      toList.add(new Recipient(rec));
                    }
                    if(theEmail.ccIds != null && theEmail.ccIds.contains(rec.Id)) {
                      ccList.add(new Recipient(rec));
                    }
                    if(theEmail.bccIds != null && theEmail.bccIds.contains(rec.Id)) {
                      bccList.add(new Recipient(rec));
                    }
                }
                List<Lead> leads = [SELECT Id, Email, FirstName, LastName FROM Lead WHERE Id IN: allIds];
                for(Lead rec: leads) {
                    if(theEmail.toIds != null && theEmail.toIds.contains(rec.Id)) {
                      toList.add(new Recipient(rec));
                    }
                    if(theEmail.ccIds != null && theEmail.ccIds.contains(rec.Id)) {
                      ccList.add(new Recipient(rec));
                    }
                    if(theEmail.bccIds != null && theEmail.bccIds.contains(rec.Id)) {
                      bccList.add(new Recipient(rec));
                    }
                }
            }
        }
    }
    public class Recipient {
        public String name {get; set;}
        public String text {get; set;}
        public String email {get; set;}
        public String id {get; set;}
        public String displayName { get{
            System.debug('displayName' + displayName);
            if(String.isBlank(name.trim()) || email.trim() == name.trim()) {
                System.debug('displayName' + email.trim());
                return email.trim();
            } else {
                System.debug('displayName' + name.trim() + ' <' + email.trim() + '>');
                return name.trim() + ' <' + email.trim() + '>';
            }
        } set;}
        public Recipient(User rec) {
            id = rec.Id;
            name = rec.FirstName + ' ' + rec.LastName;
            name = name.trim();
            email = rec.Email;
            text = rec.Email;
        }
        public Recipient(Lead rec) {
            id = rec.Id;
            name = rec.FirstName + ' ' + rec.LastName;
            name = name.trim();
            email = rec.Email;
            text = rec.Email;
        }
        public Recipient(Contact rec) {
            id = rec.Id;
            name = rec.FirstName + ' ' + rec.LastName;
            name = name.trim();
            email = rec.Email;
            text = rec.Email;
        }
        public Recipient(String address) {
            name = address;
            name = name.trim();
            email = address;
            text = address;
            id = null;
            System.debug('The Email'+email);
        }
    }
    public Boolean inConsole {get; set;}
    public PageReference setInConsole() {
        inConsole = true;
        return null;
    }
    public Case correctCase {get; set;}
    private EmailMessage theOriginalMessage {get; set;}
    private Boolean isReply {get; set;}
    private Boolean isFwd {get; set;}
    private String fwdMailId {get; set;}
    public EmailRecipients recipients {get; set;}
    public void validate() {
        List<String> caseEmailSupportRTNames = new List<String>{'Outbound Email Support'};
        List<String> inboundAndOutboundRTNames = new List<String>{'Outbound Email Support', 'Inbound Email Support'};
        Map<Id, RecordType> inboundAndOutboundRTMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType  where sObjectType= 'Case' AND Name IN :inboundAndOutboundRTNames]);
        Map<Id, RecordType> caseEmailSupportRTMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType  where sObjectType= 'Case' AND Name IN :caseEmailSupportRTNames]);
        List<Case> childCaseRecordList;
        Case parentCase;
        toAll = ApexPages.currentPage().getParameters().get('toAll');
        replyMailId = ApexPages.currentPage().getParameters().get('replyMailId');
        fwdMailId = ApexPages.currentPage().getParameters().get('fwdMailId');
        if(String.isNotBlank(fwdMailId)){
         attachments=[Select Name,ParentId,BodyLength,Body from Attachment where ParentId =:fwdMailId];
        }
          if(String.isNotBlank(fwdMailId) && attachments.size() == 0)  
              {
                 attachments=null; 
              }
        Set<Id> idSet = new Set<Id>{replyMailId, fwdMailId};
        idSet.remove(null);
        if(ApexPages.currentPage().getParameters().get('Id') != null) {
            System.debug('Id' + ApexPages.currentPage().getParameters().get('Id'));
            passedInFrom = queryCase((Id)ApexPages.currentPage().getParameters().get('Id'));
            System.debug('....,,,,,,,,,'+passedInFrom);
            composeOnLoad = true;
        }
        if(ApexPages.currentPage().getParameters().get('composeEmail') == 'true') {
            composeOnLoad = true;
        }
        if(ApexPages.currentPage().getParameters().get('inConsole') != null) {
            inConsole = Boolean.valueOf(ApexPages.currentPage().getParameters().get('inConsole'));
        }
        if(passedInFrom != null && passedInFrom.recordTypeId == externalSupportRTId) {//passed in from parent
            parentCase = passedInFrom;
            // If Send an Email from PGi Client External Support Case Record and parent Id exits
            if(parentCase != null) {
                childCaseRecordList = [SELECT Id, CaseNumber, RecordTypeId, ParentId FROM Case WHERE ParentId =: parentCase.Id AND RecordTypeId IN: caseEmailSupportRTMap.keySet()];
                if(childCaseRecordList.size() > 0){
                    correctCase = childCaseRecordList[0];
                    throw new EmailComposerException('There is already a child case for emails, please use it for email correspondence. Please use case #' + childCaseRecordList[0].CaseNumber);
                }
            }
        } else if(passedInFrom != null && inboundAndOutboundRTMap.get(passedInFrom.recordTypeId) != null){
            currentCase = passedInFrom;
        }
        if(idSet.isEmpty()) {
            return;
        }
        List<EmailMessage> emList = [SELECT Id, TextBody, HtmlBody, Subject, FromAddress, FromName, MessageDate, ToAddress, ToIds, CcAddress, CcIds, BccAddress, BccIds FROM EmailMessage WHERE Id IN: idSet LIMIT 1];
        if(emList.isEmpty()) {
            return;
        }
        theOriginalMessage = emList[0];
        recipients = new EmailRecipients(theOriginalMessage);
        if(String.isNotBlank(replyMailId)) {
            isReply = true;
            subject = theOriginalMessage.Subject;
            if(String.isNotBlank(subject) && !subject.startsWithIgnoreCase('re:')){
                subject = 'RE: ' + subject;
            }
            System.debug('toAll:' + toAll);
            if(String.isBlank(toAll) || toAll != 'true') {
                recipients.ccList = new List<Recipient>();
                recipients.bccList = new List<Recipient>();
            } else {

            }
        } else if(String.isNotBlank(fwdMailId)){
            isFwd = true;
            subject = theOriginalMessage.Subject;
            if(String.isNotBlank(subject) && !subject.startsWithIgnoreCase('FWD:')){
                subject = 'FWD: ' + subject;
            }
        }
        System.debug('The page Id'+ApexPages.currentPage().getParameters().get('Id'));
        
        //find a match in the to line for the FROM address

                Boolean fromFound = false;
                for(Integer i = 0; i < recipients.toList.size(); i++) {
                    for(Email_SLA_Management__c sla: emailSlaMap.values()) {
                        if(String.isNotBlank(sla.From_Address__c)) {
                            System.debug(recipients.toList[i]);
                            System.debug(SLA.From_Address__c);
                            Recipient r = recipients.toList[i];
                            if(r.Email.trim() == sla.From_Address__c.trim()) {
                                fromAddress = sla.Id;
                                // if(!isFwd) {
                                //     // if(sla.From_Address__c.trim() == theOriginalMessage.FromAddress.trim()) {
                                //     //     toAddress = theOriginalMessage.toAddress;
                                //     //     System.debug(toAddress);
                                //     // } else {
                                //     //     toAddress = theOriginalMessage.FromAddress;

                                //     //     System.debug(toAddress);
                                //     // }
                                // }
                                fromFound = true;
                                recipients.toList.remove(i);
                                break;
                            }
                        }
                    } 
                    if(fromFound) {
                        break;
                    }
                }

                // if(String.isNotBlank(fromAddress)) {
                //     generatePreview(theEmailTemplate);
                //     break;
                // }
                if(!fromFound) {
                    for(Integer i = 0; i < recipients.ccList.size(); i++) {
                        for(Email_SLA_Management__c sla: emailSlaMap.values()) {
                            if(String.isNotBlank(sla.From_Address__c)) {
                                Recipient r = recipients.ccList[i];
                                if(r.Email.trim() == sla.From_Address__c.trim()) {
                                    //fromAddress = sla.Id;
                                    // if(!isFwd) {
                                    //     if(sla.From_Address__c.trim() == theOriginalMessage.FromAddress.trim()) {
                                    //         toAddress = theOriginalMessage.toAddress;
                                    //     } else {
                                    //         toAddress = theOriginalMessage.FromAddress;
                                    //     }
                                    // }
                                    fromFound = true;
                                    recipients.ccList.remove(i);
                                    break;
                                }
                            }
                        }
                        if(fromFound) {
                            break;
                        }
                    }
                }
        System.debug('toAll:' + toAll);
        System.debug('isReply:' + isReply);
        if(isReply && toAll != 'true') {
            //toAddress = theOriginalMessage.FromAddress;
            toAddress = recipients.toListString;
        } 
        if(toAll == 'true') {
            toAddress = recipients.toListString;
            ccAddress = recipients.ccListString;
        }
        

        if(String.isNotBlank(fromAddress)) {
            generatePreview(theEmailTemplate);
            
        } else if(String.isBlank(emailBody)) {
            emailBody = generateOriginalThread(theOriginalMessage);
        }
        
    }
    public String generateOriginalThread(EmailMessage theOriginalMessage) {
        String originalThread = '';
        if(theOriginalMessage != null && (isFwd || isReply)){
            // if(theOriginalMessage == null) {
                
            //     return '';
            // }
            /*        --------------- Original Message ---------------
            From: PGi Salesforce Support [salesforcecrmsupport@pgi.com]
            Sent: 11/18/2019 4:50 PM
            To: tim.barsotti@gmail.com
            Subject: Re: Sandbox: test [ ref:_00DK0XK1aw._500K0H5aeN:ref ]
            */
            EmailRecipients recipientList = new EmailRecipients(theOriginalMessage);
            originalThread =  '<br/><br/>';
            if(isFwd) {
                originalThread += '--------------- Forwarded Message ---------------';
            } else {
                originalThread += '--------------- Original Message ---------------';
            }
            originalThread += '<br/>';
            originalThread += 'From: ' + theOriginalMessage.FromName;
            originalThread += '<br/>';
            originalThread += 'Sent: ' + theOriginalMessage.MessageDate.format('MM/dd/YYYY h:mm a z');
            originalThread += '<br/>';
            System.debug('recipientList.toListString: '+recipientList.originalToListString);
            if(String.isNotBlank(recipientList.originalToListString)) {
                originalThread += 'To: ' + recipientList.originalToListString;
                originalThread += '<br/>';
            }
            if(String.isNotBlank(recipientList.ccListString)) {
                originalThread += 'CC: ' + recipientList.ccListString;
                originalThread += '<br/>';
            }
            originalThread += 'Subject: ' + theOriginalMessage.Subject;
            originalThread += '<br/>';
            originalThread += '<br/>';
            if(String.isNotBlank(theOriginalMessage.HtmlBody)) {
                originalThread += theOriginalMessage.HtmlBody;
            } else {
                String textBody = theOriginalMessage.TextBody;
                textBody = textBody.replace('\r\n', '<br/>');
                textBody = textBody.replace('\n', '<br/>');
                textBody = textBody.replace('\r', '<br/>');
                
                originalThread += textBody;
            }
        }
        System.debug('originalThread: '+originalThread);
        return originalThread;
    }
    
    public Boolean composeOnLoad {get; set;}
    public void deleteCase() {
        if(createdCaseOnPageLoad) {
            try {
                delete currentCase;
                currentCase = null;
                showForm = false;
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to delete case: ' + e.getMessage()));
                return;
            }
        }
        showForm = false;
    }
    public Pagereference send() {
        //TODO - add try catch
        Pagereference pr;
        try {
            
            if(validParent()) {
                 System.debug('Hello');
                if(fromAddress == null) {
                    throw new EmailComposerException('Please select a from address');
                }
                if(sendEmail()) {
                    System.debug('Hello');
                    if(attachments != null){
                        List<Attachment> attachmentsToDelete = new List<Attachment>();
                        for(Attachment att: attachments) {
                            String parent = (String)att.ParentId;
                            if(parent.startsWith('500')) {
                                attachmentsToDelete.add(att);
                            }
                        }
                        DELETE attachmentsToDelete;
                    }
                // Delete [Select Name,BodyLength,Body from Attachment where ParentId =:currentCase.Id AND Description = 'Email-Temp-Attachment'];    
                    if(passedInFrom != null && inConsole) {
                        pr = new Pagereference('/apex/CloseConsoleTab');
                    } else {
                        pr = new Pagereference('/' + currentCase.Id);
                    }
                    pr.setRedirect(true);
                }
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        return pr;
    }
    public Boolean validParent() {
        List<String> caseEmailSupportRTNames = new List<String>{'Outbound Email Support', 'Inbound Support'};
        Map<Id, RecordType> caseEmailSupportRTMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType  where sObjectType= 'Case' AND Name IN :caseEmailSupportRTNames]);
        // if(em.ParentId != null) {
        Case current = queryCase(currentCase.Id);
        if(currentCase.ParentId != null ) {
            Case intendedParent = queryCase(currentCase.ParentId);
                if(current.parentId != intendedParent.Id) {
                    if(intendedParent.RecordTypeId == externalSupportRTId) {
                        List<Case> childCaseRecordList = [SELECT Id, CaseNumber, RecordTypeId, ParentId FROM Case WHERE ParentId =: intendedParent.Id AND RecordTypeId IN: caseEmailSupportRTMap.keySet()];
                        if(childCaseRecordList.size() > 0){
                            correctCase = childCaseRecordList[0];
                            throw new EmailComposerException('There is already a child case for emails, please use it for email correspondence. Please use case #' + childCaseRecordList[0].CaseNumber);
                        }
                    }
                }
        }

        return true;
    }
    public Pagereference changeCase() {
 
        try{ 
            validParent();
        }
         catch( exception e) {
             
        }
       
        if(currentCase != null) {
            delete [Select Name,BodyLength from Attachment where (ParentId =:currentCase.Id) AND Description = 'Email-Temp-Attachment'];
        }
        if(createdCaseOnPageLoad) {
            delete currentCase;
        }
        this.currentCase = null;
        
        this.currentCase = queryCase(correctCase.Id);
        this.passedInFrom = null;
        
        this.em = null;


        PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
        pr.getParameters().put('Id', correctCase.Id);
        ApexPages.currentPage().getParameters().put('Id', correctCase.Id);
        init();

        this.correctCase = null;
        pr.setRedirect(false);
        return null;
    }
    public Pagereference validateParentCase() {
        try {
            validParent();
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        return null;
    }
    public Boolean sendEmail() {
        try {
            if(createdCaseOnPageLoad) {
                //if we created this case, assign ownership of case
                if(emailSlaMap.get(fromAddress) != null && String.isNotBlank(emailSlaMap.get(fromAddress).Default_Queue__c)) {
                    String queueName = emailSlaMap.get(fromAddress).Default_Queue__c;
                    System.debug('The QUEUE'+queueName);
                    try {
                        QueueSobject q = [SELECT Id, Queue.Id, Queue.Name, Queue.DeveloperName, SobjectType FROM QueueSobject WHERE SobjectType = 'Case' AND Queue.DeveloperName =: queueName];
                        currentCase.OwnerId = q.Queue.Id;
                    } catch (Exception e) {
                        System.debug('Test');
                    }

                }
            }
            
            // Setting Attachments to email
             List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

             System.debug('attachments: '+attachments);
            if(attachments != null)
            {
                for (Attachment attachItr : attachments)
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(attachItr.Name);
                    efa.setBody(attachItr.Body);
                    System.debug('efa: '+efa);
                    fileAttachments.add(efa);
                }
            }

            System.debug('fileAttachments: '+fileAttachments);
            // now create our SingleEmailMessage to send out.
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            // concatenate all Bcc Addresses
            if (toAddress != null && toAddress != '') {
                singleEmailMsg.setToAddresses(toAddress.split(';'));
            }
            // concatenate all CC Addresses
            if (ccAddress != null && ccAddress != '') {
                singleEmailMsg.setCcAddresses(ccAddress.split(';'));
            }
            if (bccAddress != null && bccAddress != ''){
                singleEmailMsg.setBccAddresses(bccAddress.split(';'));
            }
            
            // singleEmailMsg.setReplyTo(fromAddress);
            if (subject != null && subject != '') {
                if(!subject.contains(getThreadId(currentCase.Id))) {
                    subject += ' ' + getThreadId(currentCase.Id);
                }
                singleEmailMsg.setSubject(subject);
            } else {
                throw new EmailComposerException('Please specify a subject');
            }
            if (emailBody != null && emailBody != '') {
                if(!emailBody.contains(getThreadId(currentCase.Id))) {
                    emailBody += getThreadId(currentCase.Id);
                }
                singleEmailMsg.setHtmlBody(emailBody);
            }
            if(attachments != null  && !fileAttachments.isEmpty()){
                System.debug('ffff: ');
                singleEmailMsg.setFileAttachments(fileAttachments);
            }
            // Decimal caseOutboundCount =[Select Count_of_Outbound_Emails__c 
            //                                     FROM Case 
            //                                     WHERE Id =:currentCase.Id].Count_of_Outbound_Emails__c;
            Case objCase = [Select Count_of_Outbound_Emails__c,SLA_Time_Remaining2__c,Count_of_Outbound_Emails_within_SLA__c,SLA_Time_to_Complete__c
                                                                            FROM Case 
                                                                            WHERE Id =:currentCase.Id];
            
            if(objCase.Count_of_Outbound_Emails__c == null || objCase.Count_of_Outbound_Emails__c == 0){
               currentCase.Count_of_Outbound_Emails__c=1; 
            }
            else{
                currentCase.Count_of_Outbound_Emails__c = objCase.Count_of_Outbound_Emails__c +1;
            }
            if(!objCase.SLA_Time_Remaining2__c.contains('-'))
            {
               if(objCase.Count_of_Outbound_Emails_within_SLA__c == null  || objCase.Count_of_Outbound_Emails_within_SLA__c == 0){
                            currentCase.Count_of_Outbound_Emails_within_SLA__c=1; 
                    } 
                else{
                currentCase.Count_of_Outbound_Emails_within_SLA__c = objCase.Count_of_Outbound_Emails_within_SLA__c +1;
                    }
            }
            currentCase.Origin = origin;
            currentCase.ParentId = currentCase.ParentId;
            if(createdCaseOnPageLoad){
                    if(!objCase.SLA_Time_Remaining2__c.contains('-'))
                    {
                        if(objCase.Count_of_Outbound_Emails_within_SLA__c == null || objCase.Count_of_Outbound_Emails_within_SLA__c == 0){
                                currentCase.Count_of_Outbound_Emails_within_SLA__c=1; 
                        } 
                    
                    }
                currentCase.Count_of_Outbound_Emails__c = 1;
                currentCase.Description=emailBody.stripHtmlTags();
                currentCase.Subject=subject;
                currentCase.Assigned_To__c=userinfo.getuserid();
                List<String> Strlst=toAddress.split(';');
                if(Strlst.size() == 1){
                    //Ticket RT-384 Discuss with tim
                   // If there is a single email in the TO line that matches to a single PGi Client then populate the PGi Client lookup field
                     List<PGi_Client__c> pgiClientLst =[Select Id,Client_Email__c From PGi_Client__c Where Client_Email__c=:Strlst[0] Limit 2];
                    if(pgiClientLst.size() == 1){
                        System.debug('The toAll1234'+toAll);   
                        currentCase.PGi_Client__c=pgiClientLst[0].Id;
                    }
                    currentCase.SuppliedEmail = Strlst[0];
                 }
            }
            update currentCase;
            
            singleEmailMsg.setWhatId(currentCase.Id);
            singleEmailMsg.setSaveAsActivity(true);
            singleEmailMsg.setUseSignature(false);
            singleEmailMsg.setOrgWideEmailAddressId(slaFromToOrgWideEmail.get(fromAddress));
            //TODO -  INVALID_MESSAGE_ID_REFERENCE, References header is not valid singleEmailMsg.setReferences('<' + currentCase.ID + '>');
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {singleEmailMsg});
            System.debug('TheEMAILIs'+results);
            return true;
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            if(e.getMessage() != null) {
                if(e.getMessage().contains('INVALID_EMAIL_ADDRESS')) {
                    String msg = e.getMessage().substringAfter('INVALID_EMAIL_ADDRESS,');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to send: ' + msg));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to send: ' + e.getMessage()));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to send: ' + e.getMessage()));
            }
        }
        return false;
    }
    public void resetForm() {
        showForm = false;
        currentCase = null;
        toAddress = null;
        ccAddress = null;
        bccAddress = null;
        origin = null;
        composeOnLoad = false;
    }
        public void CreateAttachment() {
            attachments=[Select Name,ParentId,BodyLength,Body from Attachment where (ParentId =:currentCase.Id AND Description = 'Email-Temp-Attachment') OR ParentId =:fwdMailId];
            System.debug('The List is'+attachments);
        }
        public void deleteAttachment() {
            String attachmentId=Apexpages.currentpage().getParameters().get('attachmentId');
            Delete [Select Name,BodyLength from Attachment where ((ParentId =:currentCase.Id AND Id=:attachmentId) AND Description = 'Email-Temp-Attachment') OR (ParentId =:fwdMailId AND Id=:attachmentId)];
            CreateAttachment();
              if(attachments.size() == 0)  
              {
                 attachments=null; 
              }
            System.debug('The List is123');
        }
    public Pagereference cancel() {
        
        delete [Select Name,BodyLength from Attachment where (ParentId =:currentCase.Id) AND Description = 'Email-Temp-Attachment'];
        deleteCase();
        Pagereference pr;
        if(currentCase != null) {
            if(inConsole) {
                pr = new Pagereference('/apex/CloseConsoleTab');
            } else {
                pr = new Pagereference('/' + currentCase.Id);
            }
        } else {
            pr = new Pagereference('/apex/SendAnEmail');
        }
        pr.setRedirect(true);
        return pr;
    }

    private Pagereference generatePreview(EmailTemplate emailTemplate) {
        System.debug(emailTemplate);
        
        if(emailTemplate != null && emailTemplate.Id != null) {
            emailBody = '';
            System.debug(theContact.Id);
            System.debug(emailTemplate.Id);
            System.debug(currentCase.Id);
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'invalid@emailaddr.es'};
            tempEmail.setToAddresses(toAddresses);
            tempEmail.setUseSignature(false);
            tempEmail.setSaveAsActivity(false);
            tempEmail.setSenderDisplayName('Test');
            tempEmail.setTargetObjectId(theContact.Id);
            tempEmail.setTemplateId(emailTemplate.Id);
            tempEmail.setWhatId(currentCase.Id);
            Savepoint sp = Database.setSavepoint();
            List<Messaging.SendEmailResult> results;
            try {
                results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {tempEmail});
            } catch (exception e) {
                if(e.getMessage().contains('ENTITY_IS_DELETED')) {
                    undelete currentCase;
                    results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {tempEmail});
                }
            }
            

            System.debug(tempEmail.getSubject());
            System.debug(isReply);
            System.debug(isFwd);
            if(String.isNotBlank(tempEmail.getSubject())) {
                
                if(!isReply && !isFwd) {
                    subject = tempEmail.getSubject();
                }
            }
            if(String.isNotBlank(tempEmail.getHtmlBody())){
                emailBody = tempEmail.getHtmlBody();
            } else {
            }
            System.debug(tempEmail.getHtmlBody());
            if(isReply) {
                emailBody += generateOriginalThread(theOriginalMessage);
            } else if(isFwd) {
                emailBody += generateOriginalThread(theOriginalMessage);
            }
            Database.rollback(sp);
        }
        
        return null;
    }
    public Pagereference rerenderTemplate() {
        return generatePreview(theEmailTemplate);
        // return null;
    }
    /* SELECT LIST OPTIONS FOR FROM */
    /* Only disply from addresses that are in org wide emails */
    public List<SelectOption> fromAddressOptions {get {
        if(fromAddressOptions == null) {
            fromAddressOptions = new List<SelectOption>();
            slaFromToOrgWideEmail = new Map<Id, Id>();
            
            List<SelectOption> toSort = new List<SelectOption>();
            for(Email_SLA_Management__c sla: emailSlaMap.values()) {
                for(OrgWideEmailAddress owea: orgWideEmailList) {
                    System.debug(owea.Address + '==' + sla.From_Address__c);
                    if(owea.Address == sla.From_Address__c) {
                        slaFromToOrgWideEmail.put(sla.Id, owea.Id);
                        toSort.add(new SelectOption(owea.DisplayName, sla.Id));
                    }
                }
            }
            toSort.sort();
            fromAddressOptions.add(new SelectOption('', '--Select One--'));
             for(SelectOption so: toSort) {
                fromAddressOptions.add(new SelectOption(so.getLabel(), so.getValue()));
            }
        }
        return fromAddressOptions;
    } set;}
    public List<SelectOption> statusPicklist {get {
        statusPicklist= new List<SelectOption>();
            Id recordTypeId =currentCase.RecordTypeId;
          Set<String> setPicklistValues = PicklistDescriber.describe('Case',recordTypeId,'Status');
          List<String> picklistValueForRt = new List<String>(setPicklistValues);
          for(String a :picklistValueForRt){
              statusPicklist.add(new SelectOption(a,a));
          }
        return statusPicklist;
    } set;}

    private Map<Id, Id> slaFromToOrgWideEmail {get; set;}
    public List<OrgWideEmailAddress> orgWideEmailList {get {
        if(orgWideEmailList == null) {
            orgWideEmailList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress ORDER BY DisplayName ASC];
        }
        return orgWideEmailList;
    }set;}
    private Map<Id, Email_SLA_Management__c> emailSlaMap {get{
        if(emailSlaMap == null) {
            emailSlaMap = new Map<Id, Email_SLA_Management__c>([SELECT Id, Origin__c, Email_Template__c, From_Address__c, Default_Queue__c FROM Email_SLA_Management__c WHERE From_Address__c != null ORDER BY From_Address__c]);
        }
        return emailSlaMap;
    } set;}

    /* SHARED METHODS */
    private static Case queryCase(Id caseId) {
        // try {
            return [SELECT Id, CaseNumber, ContactId,Status,RecordTypeId,Origin, Follow_Up_Email_Address__c, ParentId, Parent.CaseNumber FROM Case WHERE Id =: caseId];
        // } catch (Exception e) {
            // return null;
        }
    // }
    public static Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
    public static Id externalSupportRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Client_External_Support').getRecordTypeId();
    public static String getThreadId(String caseId){
        return '[ ref:_'
            + UserInfo.getOrganizationId().left(5)
            + UserInfo.getOrganizationId().mid(10,5) + '._'
            + caseId.left(5)
            + caseId.mid(9, 6) + ':ref ]';
    }
    public Pagereference selectTemplate() {
        String templateId = ApexPages.currentPage().getParameters().get('selectedTemplate');
        this.theEmailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE Id =: templateId];
        generatePreview(theEmailTemplate);
        return null;
    }   
}