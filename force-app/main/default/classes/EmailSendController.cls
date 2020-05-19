public class EmailSendController {
    @AuraEnabled
    public static List<String> getObjectName(){
        List<String> objects=new List<String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
        for(SObjectType sot:gd){
            objects.add(sot.getDescribe().getName());
            objects.sort();  
        }
        return objects;
    }
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody){
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        mail.setToAddresses(sendTo);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
        mail.setSenderDisplayName('salesforce User'); 
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        
        // Step 5. Add your email to the master list
        mails.add(mail);
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
    }   
    
    @AuraEnabled 
    public static List<EmailTemplate> getEmailTemplate(){
        return [SELECT Id,Body,DeveloperName FROM EmailTemplate];
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
    public static String baseUrl(){
        return system.URL.getSalesforceBaseUrl().toExternalForm();
    }
    @AuraEnabled 
    public static List<String> getEmailfromAdd(){
        List<String> OrgWideList = new List<String>();
        OrgWideList.add('noreplylesforcecrmsupport@pgi.com');
        for(OrgWideEmailAddress org : [select id, Address from OrgWideEmailAddress])
            OrgWideList.add(org.Address);
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
        /* Attachment oAttachment = new Attachment();
oAttachment.parentId = parentId;

oAttachment.Body = EncodingUtil.base64Decode(base64Data);
oAttachment.Name = fileName;
oAttachment.Description='EmailAttach';
oAttachment.ContentType = contentType;

insert oAttachment;*/
        
        return conDocument;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
     @AuraEnabled
    public static List<sObject> getEmailTemplateValuesIntoPickList(){
       return  [SELECT Id, Name,HtmlValue, Body, EnhancedLetterheadId 
                                 FROM EmailTemplate];
    }
}