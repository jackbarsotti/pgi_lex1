public class OutboundEmailMessagesController {
public Id emailMsgId{get;set;}
    public EmailMessage emailMsg{get;set;}
    public Id ObjcaseId{get;set;}
    public String createdDate{get;set;}
    public String lastModifiedDate{get;set;}
    public transient String htmlBody{get;set;}
    public List<Attachment> attachments{get;set;} 
    public OutboundEmailMessagesController(ApexPages.StandardController controller) {
        emailMsgId = ApexPages.currentPage().getParameters().get('emailMsgId');   
        ObjcaseId=ApexPages.currentPage().getParameters().get('ObjcaseId');
            emailMsg=[SELECT Id,CreatedDate, LastModifiedDate,EmailTemplateId,MessageDate,ParentId,Status, CreatedById, LastModifiedById, FromAddress, FromName, ToAddress, CcAddress, BccAddress, Subject, HtmlBody, TextBody 
                      FROM EmailMessage 
                      Where Id=:emailMsgId];
            createdDate=emailMsg.CreatedDate.format();
            lastModifiedDate=emailMsg.LastModifiedDate.format();
            attachments=[SELECT Name,BodyLength,LastModifiedDate, CreatedById 
                         FROM Attachment 
                         WHERE ParentId=:emailMsgId];
            if(attachments.size() == 0)  
            {
                attachments=null; 
            } 
            if(String.isNotBlank(emailMsg.HtmlBody)) {
                htmlBody=emailMsg.HtmlBody.stripHtmlTags();
            } else {
                htmlBody = emailMsg.textBody;
            }
    }
    public void deleteAttachment() {
        String attachmentId=Apexpages.currentpage().getParameters().get('attachmentId');
        Delete [Select Id from Attachment where Id =:attachmentId];
        attachments=[Select Name,BodyLength,LastModifiedDate, CreatedById,Body from Attachment where ParentId=:emailMsgId];
        if(attachments.size() == 0)  
        {
            attachments=null; 
        } 
    } 
}