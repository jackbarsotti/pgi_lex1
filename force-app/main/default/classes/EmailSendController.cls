public class EmailSendController {
    @AuraEnabled
    public static Financial_Request__c getrecord(String recordId){
        return [SELECT Id,Name,Subject__c FROM Financial_Request__c WHERE Id=:recordId];
    }
    @AuraEnabled
    public static List<String> getObjectName1(){
        List<String> objects=new List<String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
        for(SObjectType sot:gd){
            objects.add(sot.getDescribe().getName());
            objects.sort();  
        }
        return objects;
    }
    @AuraEnabled
    public static string getObjectName(){
        Map<String,String> objects=new Map<String,String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
        for(SObjectType sot:gd){
            objects.put(sot.getDescribe().getName(),sot.getDescribe().getLabel()); 
        }
        return JSON.serialize(objects);
    }
    @AuraEnabled 
    public static void sendMailMethod(String relatedToRecord,String addTo,String cc,String bcc,String toAddress,String fromEmail,String relatedToObject,String mSubject,String mbody,String parentRecord){
        
        System.debug('The relatedToRecord'+relatedToRecord);
        System.debug('The addTo'+addTo);
        System.debug('The cc'+cc);
        System.debug('The bcc'+bcc);
        System.debug('The toAddress'+toAddress);
        System.debug('The fromEmail'+fromEmail);
        System.debug('The mSubject'+mSubject);
        System.debug('The parentRecord '+parentRecord );
        String toAdd = [SELECT Email FROM Contact WHERE Id =: toAddress].Email;   
        
        Set<Id> conDocId = new Set<Id>();
        for(ContentDocumentLink conDoc : [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType
                                          FROM ContentDocumentLink 
                                          WHERE LinkedEntityId =: parentRecord 
                                          AND ContentDocument.Description ='EmailAttach']) {
                                              conDocId.add(conDoc.ContentDocumentId);
                                          }
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        if(!conDocId.isEmpty())
        {
            for (ContentVersion  conVer : [Select id,Title,versiondata,FileType FROM contentversion
                                           WHERE ContentDocumentId  =: conDocId])
            {
                System.debug('Test321');
                System.debug('conVer.FileType'+conVer.Title);
                String name = conVer.Title;
                blob WOCFbody = conVer.versiondata;
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(name.substringBefore('.'));
                efa.setBody(WOCFbody);
                fileAttachments.add(efa);
            }
        }
        System.debug('The conver'+fileAttachments.size());
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        
        System.debug('The to Address'+toAdd);
        List<String> toAddList = new List<String>();
        toAddList.add(toAdd);
        //sendTo.add(mMail);
        System.debug('The to Address'+toAdd.split(' '));
        singleEmailMsg.setToAddresses(toAdd.split(' '));
        
        // concatenate all CC Addresses
        if (cc != null && cc != '') {
            singleEmailMsg.setCcAddresses(cc.split(' '));
        }
        if (bcc != null && bcc != ''){
            singleEmailMsg.setBccAddresses(addTo.split(' '));
        }
        // singleEmailMsg.setReplyTo(fromAddress);
        if (mSubject != null && mSubject != '') {
            
            singleEmailMsg.setSubject(mSubject);
        } 
        if (mbody != null && mbody != '') {
            singleEmailMsg.setHtmlBody(mbody);
        }
        if(!fileAttachments.isEmpty()){
            singleEmailMsg.setFileAttachments(fileAttachments);
        }
        singleEmailMsg.setTargetObjectId(toAddress);
        singleEmailMsg.setSaveAsActivity(true);
        singleEmailMsg.setUseSignature(false);
        List<Messaging.SendEmailResult> results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {singleEmailMsg});     
        System.debug('The Result'+results);
        if(results[0].isSuccess()){
            Delete [SELECT id 
                    FROM contentDocument 
                    WHERE id =: conDocId];
        }
    }   
    
    @AuraEnabled 
    public static List<EmailTemplate> getEmailTemplateList(String folderId){
        return  [SELECT Id,Body,Subject,HtmlValue ,Name,DeveloperName,FolderId,TemplateType, Description,Folder.Name, FolderName 
                 FROM EmailTemplate  
                 where FolderId =:folderId];
    }
    @AuraEnabled 
    public static User getUser(){
        return  [SELECT Id,Name,Email 
                 FROM User 
                 WHERE Id=:userinfo.getuserid()];
    }
    /* @AuraEnabled 
public static List<Attachment> getAttachment(String recordId){
return [SELECT Id,Name,ContentType, BodyLength FROM Attachment Where Description='EmailAttach' AND ParentId=:recordId];
}*/
    @AuraEnabled
    public static List<contentDocument> getContentDoc(String recordId){
        Set<Id> conDocId = new Set<Id>();
        for(ContentDocumentLink conDoc : [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType
                                          FROM ContentDocumentLink 
                                          WHERE LinkedEntityId =: recordId AND ContentDocument.Description ='EmailAttach']) {
                                              conDocId.add(conDoc.ContentDocumentId);
                                          }
        return [Select id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument WHERE id =: conDocId];      
    }
    @AuraEnabled 
    public static void delcontentDocument(String recordId){
        Delete [Select id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument WHERE id =: recordId];
    }
    
    @AuraEnabled 
    public static List<String> getEmailfromAdd(){
        List<String> OrgWideList = new List<String>();
        User userObj =[Select Name,Email From User where Id = : userinfo.getuserid()];
        OrgWideList.add('noreplylesforcecrmsupport@pgi.com');
        OrgWideList.add(userObj.Name+'<'+userObj.Email+'>');
        for(OrgWideEmailAddress org : [select id, Address,DisplayName  from OrgWideEmailAddress])
            OrgWideList.add(org.DisplayName+'<'+org.Address+'>');
        return OrgWideList;
    }
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getuserid();//Owner of the file
        cVersion.Title = fileName;//Name of the file
        cVersion.Description ='EmailAttach';
        cVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
        Insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = parentId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
        
        return conDocument;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug('appending');
        ContentVersion a = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :fileId
        ];
        String existingBody = EncodingUtil.base64Encode(a.VersionData);
        a.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
        
        /*Attachment a = [
SELECT Id, Body
FROM Attachment
WHERE Id =: fileId
];

String existingBody = EncodingUtil.base64Encode(a.Body);

a.Body = EncodingUtil.base64Decode(existingBody + base64Data);

update a;*/
    }
    
    
    @AuraEnabled
    public static Map<Id,List<EmailTemplate>> getEmailTempaltes1(){
        Map<Id,List<EmailTemplate>> folderIdVsTemplateMap = new Map<Id,List<EmailTemplate>>();
        Set<Id> folderId = new Set<Id>();
        folderId.add(UserInfo.getOrganizationId());
        for(Folder folderObj : [SELECT Id,Name FROM Folder WHERE Type='Email']){
            folderId.add(folderObj.Id);
        }
        for(EmailTemplate emailtemp : [ SELECT Id, FolderId,TemplateType,Description, HtmlValue, FolderName, isActive, body,Name,subject 
                                       FROM EmailTemplate 
                                       WHERE isActive= true AND FolderId =: folderId ]){ 
                                           if( !folderIdVsTemplateMap.containskey(emailtemp.FolderId)){
                                               folderIdVsTemplateMap.put(emailtemp.FolderId,new List<EmailTemplate>{});
                                           }
                                           folderIdVsTemplateMap.get(emailtemp.FolderId).add(emailtemp);
                                       }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            
            
            return folderIdVsTemplateMap;
        }
        return null;
    }
    @AuraEnabled
    public static List<EmailTemplate> getEmailTempaltes(){
        Map<Id,List<EmailTemplate>> folderIdVsTemplateMap = new Map<Id,List<EmailTemplate>>();
        Set<Id> folderId = new Set<Id>();
        folderId.add(UserInfo.getOrganizationId());
        for(Folder folderObj : [SELECT Id,Name FROM Folder WHERE Type='Email']){
            folderId.add(folderObj.Id);
        }
        return [ SELECT Id, FolderId,TemplateType,Description, HtmlValue, FolderName, isActive, body,Name,subject 
                FROM EmailTemplate 
                WHERE isActive= true AND FolderId =: folderId ];
        
    }
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
        
        @AuraEnabled 
        public String emailDescription{get;set;}
        
        @AuraEnabled 
        public String emailTemplateType{get;set;}
    } 
    
    @AuraEnabled
    public static Map<Id,String> getFolders(){
        Map<Id,String> folderIdToMame = new Map<Id,String>();
        EmailTemplate emailTemp = [SELECT Id,Body,Subject,HtmlValue ,Name,DeveloperName,FolderId,TemplateType, Description, FolderName 
                                   FROM EmailTemplate  
                                   where FolderId =: UserInfo.getOrganizationId() LIMIT 1];
        folderIdToMame.put(emailTemp.FolderId, emailTemp.FolderName);
        for(Folder folderObj : [SELECT Id, Name, DeveloperName, Type 
                                FROM Folder 
                                WHERE Type  ='Email']){
                                    folderIdToMame.put(folderObj.Id,folderObj.Name);                
                                }
        
        return folderIdToMame;
    }
    
    @AuraEnabled
    public static emailTemplateMergedata getTempletemergeData(String emailTempId,String toaddressId,String mergeFieldObjId){
        String emailBody = '';
            String Subject = '';
        if(emailTempId != null && emailTempId != '') {
           /* User user = [select email, firstName, lastName from User where id = :UserInfo.getUserId()];
              Contact tempContact = new Contact(email = user.email, firstName = user.firstName, lastName = user.lastName);
              insert tempContact;*/
            
            System.debug('The TempId'+emailTempId);
            System.debug('The toaddressId'+toaddressId);
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'invalid@emailaddr.es'};
                tempEmail.setToAddresses(toAddresses);
            tempEmail.setUseSignature(false);
            tempEmail.setSaveAsActivity(false);
            tempEmail.setSenderDisplayName('Test');
            tempEmail.setTargetObjectId(toaddressId);
            tempEmail.setTemplateId(emailTempId);
            tempEmail.setWhatId(mergeFieldObjId);
            Savepoint sp = Database.setSavepoint();
            List<Messaging.SendEmailResult> results;
                results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {tempEmail});
            
            
            
            System.debug(tempEmail.getSubject());
            if(String.isNotBlank(tempEmail.getSubject())) {
                    subject = tempEmail.getSubject();
            }
            if(String.isNotBlank(tempEmail.getHtmlBody())){
                emailBody = tempEmail.getHtmlBody();
            } 
            
            Database.rollback(sp);
        }
        emailTemplateMergedata emailWrap = new emailTemplateMergedata();
        emailWrap.subject = subject;
        emailWrap.emailBody = emailBody;
        return emailWrap;
    }
    
    public class emailTemplateMergedata{
        
        @AuraEnabled 
        public String subject{get;set;}
        
        @AuraEnabled 
        public String emailBody{get;set;}
    }
}