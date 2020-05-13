@IsTest
public class RFCWithdrawApprovalTest {
	@IsTest
    public static void testRFC() {
        Request_For_Change__c rfc = PGITestUtilities.createRFC(true);
        rfc.Status__c = 'Approved'; 
        update rfc;
        ApexPages.StandardController sc  = new Apexpages.StandardController(rfc);
		RFCWithdrawApproval ext = new RFCWithdrawApproval(sc);
		ext.withdraw();
        rfc.Status__c = 'Complete'; 
        update rfc;
		ext.withdraw();
        rfc.Status__c = 'Draft'; 
        update rfc;
		ext.withdraw();        
        
    }
}