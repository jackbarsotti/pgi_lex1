trigger CheckAttachmentsonPCR on Attachment (after insert, after update,after delete) {

Set<Id> parentIds = new Set<Id>();
Set<Id> PCRwithattmt = new Set<Id>();

for (Attachment att : Trigger.isDelete ? Trigger.Old : Trigger.new){
    parentIds.add(att.parentId);       
}
system.debug('ARC debug parentids:'+parentids);

List<ProductCustomizationRequest__c> PCRlist = [SELECT id FROM ProductCustomizationRequest__c WHERE ID IN :parentIds];
List<Attachment> attachmentList = [SELECT id,parentid FROM Attachment WHERE parentid IN :parentIds];

for(Attachment att : attachmentList)
{
    PCRwithattmt.add(att.parentid);    
}
for(ProductCustomizationRequest__c pcr : PCRlist)
{
    if(PCRwithattmt.contains(pcr.id))
        pcr.Has_Attachments__c = True;
    else
        pcr.Has_Attachments__c = False;    
} 
update PCRlist;
}