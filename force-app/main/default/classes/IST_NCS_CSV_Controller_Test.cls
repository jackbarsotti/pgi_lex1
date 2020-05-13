@isTest
private class IST_NCS_CSV_Controller_Test {

/*	@isTest static void none() {
        Account acct = PGITestUtilities.getAccountDetails();
        INSERT acct;

        Opportunity opp = PGITestUtilities.getOpportunityDetails();
        opp.AccountId = acct.Id;
        INSERT opp;

        Implementation_Services__c ist = new Implementation_Services__c();
        ist.Related_Opportunity__c = opp.Id;
        ist.Related_Opportunity__r = opp;
        
        
        INSERT ist;

        PageReference ncs = Page.IST_NCS_CSV;
        ncs.getParameters().put('id', ist.Id);
        Test.setCurrentPage(ncs);
        IST_NCS_CSV_Controller ctrl = new IST_NCS_CSV_Controller(new ApexPages.StandardController(ist));

        System.assertEquals(false, ctrl.forAddresses, 'For Addresses');

     //   System.assertEquals(0, ctrl.addresses.size(), 'Address Count');

        System.assertEquals('None', ctrl.filename, 'Filename');

     //   System.assertEquals(0, ctrl.rows.size(), 'Rows');
	}

	 @isTest static void addresses() {
         Account acct = PGITestUtilities.getAccountDetails();
       INSERT acct;

         Opportunity opp = PGITestUtilities.getOpportunityDetails();
         opp.AccountId = acct.Id;
         INSERT opp;

         Implementation_Services__c ist = new Implementation_Services__c();
         ist.Related_Opportunity__c = opp.Id;
         ist.Related_Opportunity__r = opp;
        
        INSERT ist;

         List<Address__c> addrs = new List<Address__c>();
         for (Integer i = 0; i < 55; i++)
            addrs.add(new Address__c(Recipient_Name__c='1', City__c='2', Country__c='US'));
         INSERT addrs; 

    //    addrs = [SELECT Id, Name, Recipient_Name__c, Street_Address_1__c, Street_Address_2__c, City__c, Postal_Code__c, State__c, Country__c FROM Address__c ORDER BY CreatedDate DESC LIMIT 55];

         PageReference ncs = Page.IST_NCS_CSV;
         ncs.getParameters().put('id', ist.Id);
         ncs.getParameters().put('address', 'true');
         Test.setCurrentPage(ncs);
         IST_NCS_CSV_Controller ctrl = new IST_NCS_CSV_Controller(new ApexPages.StandardController(ist));

         System.assertEquals(true, ctrl.forAddresses, 'For Addresses');

   //      System.assertEquals(55, ctrl.addresses.size(), 'Address Count');

         System.assertEquals('Addresses', ctrl.filename, 'Filename');

         System.assertEquals('Name,Recipient,Street 1,Street 2,City,State,Postal Code,Country', ctrl.header, 'Header');

    //     System.assertEquals(55, ctrl.rows.size(), 'Rows');
      //  System.assertEquals('\n' + addrs.get(0).Name + ',1,,,2,,,US', ctrl.rows.get(0), 'Rows');
	 } 

	 @isTest static void both() {
         Account acct = PGITestUtilities.getAccountDetails();
         INSERT acct;

        Opportunity opp = PGITestUtilities.getOpportunityDetails();
         opp.AccountId = acct.Id;
         INSERT opp;

         Implementation_Services__c ist = new Implementation_Services__c();
         ist.Related_Opportunity__c = opp.Id;
         ist.Related_Opportunity__r = opp;
        
         INSERT ist;

         List<Address__c> addrs = new List<Address__c>();
         for (Integer i = 0; i < 55; i++)
             addrs.add(new Address__c(Recipient_Name__c='1', City__c='2', Country__c='US'));
         INSERT addrs; 

         PageReference ncs = Page.IST_NCS_CSV;
         ncs.getParameters().put('id', ist.Id);
         ncs.getParameters().put('address', 'true');
         ncs.getParameters().put('cpe', 'true');
         Test.setCurrentPage(ncs);
         IST_NCS_CSV_Controller ctrl = new IST_NCS_CSV_Controller(new ApexPages.StandardController(ist));

         System.assertEquals(true, ctrl.forAddresses, 'For Addresses');
         System.assertEquals('Name,Recipient,Street 1,Street 2,City,State,Postal Code,Country', ctrl.header, 'Header');
        //  System.assertEquals('Neither CPEs nor Addresses were specified for exporting', ctrl.header, 'Header');
 //        System.assertEquals(55, ctrl.rows.size(), 'Rows');
       
	 } */

}