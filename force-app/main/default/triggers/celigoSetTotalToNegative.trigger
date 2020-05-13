trigger celigoSetTotalToNegative on NetSuite_Financial__c (before insert, before update) {
	for(NetSuite_Financial__c financial : System.Trigger.new){
		if(financial.Type__c != 'Credit Memo')
			continue;
			
		if(financial.Total__c != null && financial.Total__c > 0)
			financial.Total__c = 0 - financial.Total__c;
		
		if(financial.Subtotal__c != null && financial.Subtotal__c > 0)
			financial.Subtotal__c = financial.Subtotal__c * -1;
	}
}