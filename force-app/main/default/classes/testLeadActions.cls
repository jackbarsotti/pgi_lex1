@isTest
class testLeadActions {
	 //static testMethod void testLeadTriggerWithInsert() {
  //    // dummy test to fire trigger action.
  //    Lead newLead = new Lead();
  //    newLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //    newLead.Company = 'test';
  //    newLead.Email = 'qa@readytalk.com';
  //    newLead.FirstName = 'Test';
  //    newLead.LastName = 'Lead';
  //    newLead.LeadSource = 'Other';
  //    newLead.Billing_Address_Line_1__c = '123 Main';
  //    newLead.Billing_Address_Line_2__c = 'foo';
  //    newLead.Billing_City__c = 'Denver';
  //    newLead.Billing_State__c = 'CO';
  //    newLead.Billing_Country__c = 'UNITED STATES';
  //    newLead.Billing_Zip__c = '80202';
      
  //    insert newLead;
  //    System.assert(true);
      
  //  }
    
  //  static testMethod void testSyncAddressCreateWithStdOnly() {
  //  	Lead newLead = new Lead();
  //    newLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //  	newLead.Billing_Country__c = 'UNITED STATES';
  //    newLead.Country = 'United States';
  //    newLead.Street = '101 Main St.';
  //    newLead.Billing_Address_Line_1__c = '101 Main St.';
  //  	newLead.City = 'Denver';
  //    newLead.Billing_City__c = 'Denver';
  //  	newLead.Country = 'USA';
  //  	newLead.State = 'Colorado';
  //    newLead.Billing_State__c = 'CO';
  //  	newLead.PostalCode = '80202';
  //    newLead.Billing_Zip__c = '80202';
    	
  //  	Lead[] newObj = new List<Lead>();
  //  	newObj.add(newLead);
    	
  //  	LeadActions.syncAddressFields(newObj, null);
    	
  //  	System.assert('UNITED STATES'.equals(newObj[0].Country));
  //    System.assert('UNITED STATES'.equals(newObj[0].Billing_Country__c));
  //    System.assert('Denver'.equals(newObj[0].Billing_City__c));
  //    System.assert('101 Main St.'.equals(newObj[0].Billing_Address_Line_1__c));
  //    System.assert('CO'.equals(newObj[0].Billing_State__c));
  //    System.assert('80202'.equals(newObj[0].Billing_Zip__c));
  //  }
    
  //  static testMethod void testSyncAddressCreateWithCustomOnly() {
  //  	Lead newLead = new Lead();
  //    newLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //  	newLead.Billing_Country__c = 'United States';
  //    newLead.Country = 'United States';
  //    newLead.City = 'Dallas';
  //  	newLead.Billing_City__c = 'Dallas';
  //  	newLead.Billing_State__c = 'TX';
  //    newLead.State = 'TX';
  //  	newLead.Street = '101 Main St.';
  //    newLead.Billing_Address_Line_1__c = '101 Main St.';
  //  	newLead.Billing_Zip__c = '75230';
  //    newLead.PostalCode = '75230';
    	
  //  	Lead[] newObj = new List<Lead>();
  //    newObj.add(newLead);
      
  //    LeadActions.syncAddressFields(newObj, null);
      
  //    System.assert('UNITED STATES'.equals(newObj[0].Country), newObj[0].Country);
  //    System.assert('United States'.equals(newObj[0].Billing_Country__c), newObj[0].Billing_Country__c);
  //    System.assert('Dallas'.equals(newObj[0].City));
  //    System.assert('101 Main St.'.equals(newObj[0].Street));
  //    System.assert('TX'.equals(newObj[0].State));
  //    System.assert('75230'.equals(newObj[0].PostalCode));
      
  //  }
    
  //  static testMethod void testUpdateStdFields() {
  //    Lead newLead = new Lead();
  //    newLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //    newLead.Street = '101 Main St.';
  //    newLead.City = 'Denver';
  //    newLead.Country = 'USA';
  //    newLead.State = 'CO';
  //    newLead.PostalCode = '80202';
  //    newLead.Billing_Address_Line_1__c = '101 Main St.';
  //    newLead.Billing_City__c = 'Dallas';
  //    newLead.Billing_Country__c = 'UNITED STATES';
  //    newLead.Billing_Zip__c = '80202';
  //    newLead.Billing_State__c = 'CO';
      
  //    Lead[] newObj = new List<Lead>();
  //    newObj.add(newLead);
      
  //    Lead oldLead = new Lead();
  //    oldLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //    oldLead.Street = '101 Main St.';
  //    oldLead.City = 'Dallas';
  //    oldLead.Country = 'USA';
  //    oldLead.State = 'TX';
  //    oldLead.PostalCode = '75230';
  //    oldLead.Billing_Address_Line_1__c = '101 Main St.';
  //    oldLead.Billing_City__c = 'Dallas';
  //    oldLead.Billing_Country__c = 'UNITED STATES';
  //    oldLead.Billing_Zip__c = '25230';
  //    oldLead.Billing_State__c = 'TX';
      
  //    Lead[] oldObj = new List<Lead>();
  //    oldObj.add(oldLead);
      
  //    LeadActions.syncAddressFields(newObj, oldObj);
      
  //    System.assert('UNITED STATES'.equals(newObj[0].Country));
  //    System.assert('UNITED STATES'.equals(newObj[0].Billing_Country__c));
  //    System.assert('Dallas'.equals(newObj[0].Billing_City__c));
  //    System.assert('Denver'.equals(newObj[0].City));
  //    System.assert('101 Main St.'.equals(newObj[0].Billing_Address_Line_1__c));
  //    System.assert('101 Main St.'.equals(newObj[0].Street));
  //    System.assert('CO'.equals(newObj[0].Billing_State__c));
  //    System.assert('CO'.equals(newObj[0].State));
  //    System.assert('80202'.equals(newObj[0].Billing_Zip__c));
  //    System.assert('80202'.equals(newObj[0].PostalCode));   
      
  //  }
    
  //  static testMethod void testUpdateCustomFields() {
  //    Lead newLead = new Lead();
  //    newLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //    newLead.Street = '101 Main St';
  //    newLead.City = 'Denver';
  //    newLead.Country = 'USA';
  //    newLead.State = 'TX';
  //    newLead.PostalCode = '80202';
  //    newLead.Billing_Address_Line_1__c = '101 Main St';
  //    newLead.Billing_City__c = 'TestCity';
  //    newLead.Billing_Country__c = 'UNITED STATES';
  //    newLead.Billing_Zip__c = '75230';
  //    newLead.PostalCode = '75230';
  //    newLead.Billing_State__c = 'TX';
      
  //    Lead[] newObj = new List<Lead>();
  //    newObj.add(newLead);
      
  //    Lead oldLead = new Lead();
  //    oldLead.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypes[0].Id;
  //    oldLead.Street = '101 Main St.';
  //    oldLead.City = 'Denver';
  //    oldLead.Country = 'USA';
  //    oldLead.State = 'Colorado';
  //    oldLead.PostalCode = '80202';
  //    oldLead.Billing_Address_Line_1__c = '101 Main Street';
  //    oldLead.Billing_City__c = 'Dallas';
  //    oldLead.Billing_Country__c = 'UNITED STATES';
  //    oldLead.Billing_Zip__c = '75230';
  //    oldLead.Billing_State__c = 'TX';
      
  //    Lead[] oldObj = new List<Lead>();
  //    oldObj.add(oldLead);
      
  //    LeadActions.syncAddressFields(newObj, oldObj);
      
  //    System.assert('UNITED STATES'.equals(newObj[0].Country));
  //    System.assert('UNITED STATES'.equals(newObj[0].Billing_Country__c));
  //    System.assert('TestCity'.equals(newObj[0].Billing_City__c), newObj[0].Billing_City__c);
  //    System.assert('Denver'.equals(newObj[0].City));
  //    System.assert('101 Main St'.equals(newObj[0].Billing_Address_Line_1__c));
  //    System.assert('101 Main St'.equals(newObj[0].Street));
  //    System.assert('TX'.equals(newObj[0].Billing_State__c));
  //    System.assert('TX'.equals(newObj[0].State));
  //    System.assert('75230'.equals(newObj[0].Billing_Zip__c));
  //    System.assert('75230'.equals(newObj[0].PostalCode));   
      
  //  }
    
}