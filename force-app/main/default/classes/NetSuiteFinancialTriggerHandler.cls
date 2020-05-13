public class NetSuiteFinancialTriggerHandler extends TriggerHandler {
	public NetSuiteFinancialTriggerHandler() {
        super('NetSuiteFinancialTriggerHandler');
    }
    protected override void beforeInsert() {
        // celigoSetTotalToNegative.trigger
        celigoSetTotalToNegative();
    }
    protected override void beforeUpdate() {
        // celigoSetTotalToNegative.trigger
        celigoSetTotalToNegative();
    }
    protected override void afterInsert() {
        // FinancialAfterInsertAfterUpdate.trigger
        FinancialAfterInsertAfterUpdate();
    }
    protected override void afterUpdate() {
     	// FinancialAfterInsertAfterUpdate.trigger
        FinancialAfterInsertAfterUpdate();   
    }

    private void celigoSetTotalToNegative() {

    	for(NetSuite_Financial__c financial : (List<NetSuite_Financial__c>)Trigger.new){
			if(financial.Type__c != 'Credit Memo')
				continue;
				
			if(financial.Total__c != null && financial.Total__c > 0)
				financial.Total__c = 0 - financial.Total__c;
			
			if(financial.Subtotal__c != null && financial.Subtotal__c > 0)
				financial.Subtotal__c = financial.Subtotal__c * -1;
		}
    }

    private void FinancialAfterInsertAfterUpdate() {
    	FinancialActions.insertStartDates(Trigger.new);
    }
}