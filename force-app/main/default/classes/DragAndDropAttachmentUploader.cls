public with sharing class DragAndDropAttachmentUploader {
	public DragAndDropAttachmentUploader() {
		//parentId = '500L000000DN9MiIAL';
		parentId = ApexPages.currentPage().getParameters().get('id');
	}

	public Id parentId {get; set;}
    public List<Attachment> attachmentList {get{ 
        return [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedBy.Name, IsPrivate, BodyLength FROM Attachment WHERE ParentId =: parentId];
    } set;}
    public Id selectedAttachmentId {get; set;} 
    public PageReference navigateToAttachment() {
        PageReference pr = new PageReference('/' + selectedAttachmentId);
        return null;
    }

	@RemoteAction
    public static String uploadAttachment(String recordId, String fileBody, String fileName, String fileId, Boolean lastChunk) {

        system.debug('uploadAttachment()___' + recordId);
        system.debug('fileBody___' + fileBody);
        system.debug('fileName___' + fileName);
        system.debug('fileId___' + fileId);
        system.debug('lastChunk____' + lastChunk);

        return processAttachmentUpload(recordId, fileBody, fileName, fileId, lastChunk);
    }

    @RemoteAction
    public static String getSobjectTypeFromKeyPrefix(String objectKeyPrefix) {

    	//Id objectId = String.escapeSingleQuotes(objectKeyPrefix) + '000000000000';
    	Id objectId = String.escapeSingleQuotes(objectKeyPrefix);
    	// return string value of sObjectType
    	return String.valueOf(objectId.getSobjectType());
    }

    private static Attachment queryAttachment(String fileId) {
        return [SELECT Id, Body FROM Attachment WHERE Id = :fileId];
    }

    private static String processAttachmentUpload(String recordId, String fileBody, String fileName, String fileId, Boolean lastChunk) {
    	// create Attachment record and save to the record
        if(fileBody != null) {
            system.debug('upload-attachment_1');
            Attachment recordAttachment = new Attachment();

            if(fileId != null) {
                system.debug('upload-attachment_1a');
                recordAttachment = queryAttachment(fileId);
            }
            String newBody = '';

            if(recordAttachment.Body != null) {
                system.debug('upload-attachment_1b');
                newBody = EncodingUtil.base64Encode(recordAttachment.Body);
            }

            system.debug('upload-attachment_2');
            newBody += fileBody;
            recordAttachment.Body = EncodingUtil.base64Decode(newBody);
            if(fileId == null) {
                recordAttachment.Name = fileName;
                recordAttachment.OwnerId = UserInfo.getUserId();
                // attach to record
                recordAttachment.ParentId = recordId;
            }
            system.debug('upload-attachment_3');
            try {
                upsert recordAttachment;
            }
            catch(DMLException ex) {
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error inserting attachment'));
                system.debug(ex);
            }

            system.debug('savingLastChunk');

            if(lastChunk) {
                system.debug('LastChunk is ready');
                
            }
            return recordAttachment.Id;
            //return '00P';
        } 
        else {
            return 'Attachment Body Null';
        }
    }
}