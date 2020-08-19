@isTest
private class ChatTranscriptTriggerHandlerTest {

   static testMethod void testCaseMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        Case c = new Case(
            RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id
        );
        INSERT c;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.CaseId = c.Id;
        lct.Query_Topic__c = 'Web or Audio Meetings';
        insert lct;

        lct.Body = '<p>Test chat transcript body.</p>';
        update lct;

        Case caseRecord = [SELECT Description FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(caseRecord.Description, null);

        Id emailMessageId;
        try {
            emailMessageId = [SELECT Id FROM EmailMessage WHERE ParentId = :c.Id].Id;
        }
        catch (Exception e) {
            emailMessageId = null;
        }
        System.assertNotEquals(emailMessageId, null);
    }

    static testMethod void testFinReqMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        Financial_Request__c fr = new Financial_Request__c();
        INSERT fr;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.Financial_Request__c = fr.Id;
        insert lct;

        lct.Body = '<p>Test chat transcript body.</p>';
        update lct;

        Financial_Request__c frRecord = [SELECT CaseDescription__c FROM Financial_Request__c WHERE Id = :fr.Id];
        System.assertNotEquals(frRecord.CaseDescription__c, null);
    }


static testMethod void updateRegionFieldsMethod(){
     List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
     LiveChatVisitor lcv = new LiveChatVisitor();
     insert lcv;
     
     LiveChatTranscript lct = new LiveChatTranscript();
     lct.LiveChatVisitorId = lcv.Id;
     lct.Location = 'null, null, United States';

     if(lct.Location != null && lct.Location != '') {          
         ctList.add(lct);
      }
      
      String location = lct.Location;
      String country;
      String[] location_values = location.split(',');
      if (location_values[2].length() > 0) {
         country = location_values[2];
         lct.Location_Country__c = country;
      }
     
      Test.startTest();
      insert ctList;
      Test.stopTest();
     
}

static testMethod void updateGMDescriptionMethod(){
     List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
     LiveChatVisitor lcv = new LiveChatVisitor();
     insert lcv;

     LiveChatTranscript lct = new LiveChatTranscript();
     lct.LiveChatVisitorId = lcv.Id;
     lct.GM_Description__c = '"os":"Mac OS 10.14.6","email":"test12345@pgi.com","browserAgent":"Mozilla/5.0 ","clientID":"600374"';
     ctList.add(lct);
     
     for (LiveChatTranscript ct_new : ctList){    
        String GM_Description = ct_new.GM_Description__c;
        GM_Description = GM_Description.substring(1, GM_Description.length()-1);
        String[] values = GM_Description.split(',');
        GM_Description = String.join(values,'\n');
        ct_new.GM_Description__c = GM_Description;
        }        

      Test.startTest();
      insert ctList;
      Test.stopTest();  
}

   static testMethod void updateRelatedFieldsTest1() {
     Case objCase = new Case();
     insert objCase;
     PGi_Client__c objClient = new PGi_Client__C();
     objClient.Client_Email__c = 'test1@test.com';
     PGi_Company__c objCompany = new PGi_Company__c();
     objClient.PGi_Company__c = objCompany.Id;
     insert objClient;
     
     Account objAccount = new Account(
                                 Name='Test',
                                 Type='Direct',
                                 Website='www.pgi.com',
                                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('PGi Account').getRecordTypeId());
     insert objAccount;
     
     Contact objContact = new Contact(
                                 FirstName='Test',
                                 LastName='Test',
                                 Email='test1@test.com',
                                 Title='Ms',
                                 AccountId = objAccount.Id,
                                 RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PGi Contact').getRecordTypeId());
     insert objContact;
     Lead objLead = new Lead(
                                 FirstName='Test',
                                 LastName='Test',
                                 Email='test1@test.com',
                                 CountryCode = 'US',
                                 LeadSource = 'Web Chat',
                                 Company = 'PGi',
                                 Status = 'Assigned',
                                 CurrencyISOCode = 'USD',
                                 RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId());
     insert objLead;
     
     String testCaseNumber = [SELECT CaseNumber from CASE where Id =: ObjCase.Id].CaseNumber;
     
     List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
     List<PGi_Client__c> clientList = new List<PGi_Client__c>();
     List<string> caseNumbers = new List<string>{testCaseNumber};
     List<Contact> contactList = new List<Contact>();
     List<Lead> leadList = new List<Lead>();
     
     List<string> emailList = new List<string>();
     emailList.add(objClient.Client_Email__c);
 
     Map<string, Case> mapOfCaseByCaseNum = new Map<string, Case>();
     mapOfCaseByCaseNum.put(objCase.CaseNumber, objCase);
     
     Map<string, PGi_Client__c> mapOfClientByEmail = new Map<string, PGi_Client__c>();
     mapOfClientByEmail.put(objClient.Client_Email__c, objClient);
     
     Map<string, Contact> mapOfContactByEmail = new Map<string, Contact>();
     mapOfContactByEmail.put(objContact.Email, objContact);
     
     Map<string, Lead> mapOfLeadByEmail = new Map<string, Lead>();
     mapOfLeadByEmail.put(objLead.Email, objLead);
      
     LiveChatVisitor lcv = new LiveChatVisitor();
     insert lcv;
     
     for(Integer i = 0 ; i<=10 ;i++){
         LiveChatTranscript lct = new LiveChatTranscript();
         lct.LiveChatVisitorId = lcv.Id;
         lct.Email_Address__c = 'test'+i+'@test.com';
         lct.Case_Number__c = objCase.CaseNumber;
         ctList.add(lct);
         
         if (lct.Case_Number__c != null){
             caseNumbers.add(objCase.CaseNumber);
         }
     }

    for (LiveChatTranscript lct_new : ctList){
     if (mapOfCaseByCaseNum.containsKey(lct_new.Case_Number__c)){
            Case c = mapOfCaseByCaseNum.get(lct_new.Case_Number__c);
            lct_new.CaseId = c.Id;
            lct_new.Escalated__c = true;
      }
      if (mapOfClientByEmail.containsKey(lct_new.Email_Address__c)){
            PGi_Client__c clt = mapOfClientByEmail.get(lct_new.Email_Address__c);
            lct_new.PGi_Client__c = clt.Id;
            if(clt.PGi_Company__c != null){
                lct_new.PGi_Company__c = clt.PGi_Company__c;
            }
      }        
    
      if (mapOfContactByEmail.containsKey(lct_new.Email_Address__c)){
                Contact cnt = mapOfContactByEmail.get(lct_new.Email_Address__c);
                lct_new.ContactId = cnt.Id;
                if(cnt.AccountId != null){
                    lct_new.AccountId = cnt.AccountId;
                }
      }       
            
      //only populate the LeadId if there is no related Contact record
      if (!(mapOfContactByEmail.containsKey(lct_new.Email_Address__c)) && mapOfLeadByEmail.containsKey(lct_new.Email_Address__c)){
                Lead led = mapOfLeadByEmail.get(lct_new.Email_Address__c);
                lct_new.LeadId = led.Id;
                if(led.Account__c != null){
                    lct_new.AccountId = led.Account__c;
                }
       } 
   }      

            Test.startTest();
            insert ctList;
            Test.stopTest();
   }
   
      static testMethod void updateRelatedFieldsTest2() {
             Case objCase = new Case();
             insert objCase;
             PGi_Client__c objClient = new PGi_Client__C(Client_Email__c = 'test20@test.com'
                                                         );                                                                                                                               
             insert objClient;
             
             PGi_Client__c objClientDuplicateEmail = new PGi_Client__C(Client_Email__c = 'test20@test.com'
                                                         );                                                                                                                               
             insert objClientDuplicateEmail;
             
             Lead objLead = new Lead(
                                         FirstName='Test',
                                         LastName='Test',
                                         Email='test20@test.com',
                                         CountryCode = 'US',
                                         LeadSource = 'Web Chat',
                                         Company = 'PGi',
                                         Status = 'Assigned',
                                         CurrencyISOCode = 'USD',
                                         RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId());
             insert objLead;                                                 
              
             LiveChatVisitor lcv = new LiveChatVisitor();
             insert lcv;
             
                 LiveChatTranscript lct = new LiveChatTranscript();
                 lct.LiveChatVisitorId = lcv.Id;
                 lct.Email_Address__c = 'test20@test.com';                

            Test.startTest();
            insert lct;
            Test.stopTest();
      }
}