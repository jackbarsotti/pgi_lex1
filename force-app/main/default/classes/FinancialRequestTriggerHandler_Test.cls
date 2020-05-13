@isTest
public class FinancialRequestTriggerHandler_Test {
    @isTest
    static void getCaseComments_test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User userObj = PGITestUtilities.getTestUser(p);
        
        Case caseObj = PGITestUtilities.createCase();
        caseObj.Description = 'TestDescription';
        caseObj.Status = 'New';
        insert caseObj;
        
        Attachment attachObj = PGITestUtilities.createAttachment(caseObj.Id);
		Insert attachObj;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink contentDoc = New ContentDocumentLink();
        contentDoc.LinkedEntityId = caseObj.id;
        contentDoc.ContentDocumentId = documents[0].Id;
        contentDoc.shareType = 'I';
        insert contentDoc;
        
        CaseComment cc = PGITestUtilities.createCaseComment(caseObj.Id);
        Insert cc;
        Financial_Request__c fr = PGITestUtilities.getFinancialRequests(caseObj.Id, userObj.Id);
        Insert fr;
        
        //System.assertEquals([SELECT Id, Name  FROM Attachment WHERE ParentId = :fr.Id].Name, attachObj.Name);
        System.assertEquals([SELECT Id, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId = :fr.Id].ContentDocumentId, contentDoc.ContentDocumentId);
        
    }
    
}