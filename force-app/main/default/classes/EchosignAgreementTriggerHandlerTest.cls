@IsTest
public class EchosignAgreementTriggerHandlerTest {
	@IsTest
	public static void testDeletion() {
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.createOpportunity(testAcct, false);
        testOppty.Primary_Won_Reason__c = 'Test';
        testOppty.Competitor_s__c = 'AAPT';
        testOppty.Incumbent__c = 'Test';
        insert testOppty;
        
        echosign_dev1__SIGN_Agreement__c testESig = new echosign_dev1__SIGN_Agreement__c(
            echosign_dev1__Opportunity__c=testOppty.Id,
            echosign_dev1__Status__c = 'Out for Signature'
        );
        INSERT testESig;

        Blob body = Blob.valueOf('test');
        Attachment att1 = new Attachment(ParentId=testESig.Id, Name='eSignature Testing', Body=body);
        INSERT att1;

        Test.startTest();
        
        List<Attachment> atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :testESig.Id];
        System.assertEquals(1, atts.size(),
                           'ESig has an attachment');
        
        testESig.echosign_dev1__Status__c = 'Signed';
        UPDATE testESig;
        
        Attachment att2 = new Attachment(ParentId=testESig.Id, Name='eSignature Testing 2', Body=body);
        INSERT att2;
        
        // atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :testESig.Id];
        // System.assertEquals(1, atts.size(),
        //                    'ESig has an attachment (not the new one though)');
        
        // atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :testOppty.Id];
        // System.assertEquals(1, atts.size(),
        //                    'Opp has an attachment');
        // System.assertEquals('SIGNED: eSignature.pdf', atts.get(0).Name,
        //                    'Opp attachment named correctly');

        // Test.stopTest();
        // delete testESig;
        // System.assertEquals('Cancelled', [SELECT Agreement_Status__c FROM Opportunity].Agreement_Status__c);
	}
}