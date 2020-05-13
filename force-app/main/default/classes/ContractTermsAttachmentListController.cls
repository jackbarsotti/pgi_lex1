public without sharing class ContractTermsAttachmentListController {
    public list <Attachment> attachments {get;set;}  
    public string recId {get;set;}
    public string attachId {get;set;}
    public ContractTermsAttachmentListController( ApexPages.StandardController controller) {
        recId  = ApexPages.CurrentPage().getparameters().get('id');
        attachments = [SELECT Id, Name, CreatedById , ContentType, ParentId FROM Attachment WHERE ParentId =: recId];
    }
}