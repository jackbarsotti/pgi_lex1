public with sharing class VersionHistoryAttachmentController {
    public list <Attachment> attachments {get;set;}  
    public string recId {get;set;}
    public string attachId {get;set;}
    public VersionHistoryAttachmentController( ApexPages.StandardController controller) {
        recId  = ApexPages.CurrentPage().getparameters().get('id');
        attachments = [SELECT Id, Name, CreatedBy.Name , ContentType, ParentId FROM Attachment WHERE ParentId =: recId];
    }
}