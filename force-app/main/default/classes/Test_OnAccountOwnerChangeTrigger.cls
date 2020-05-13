@isTest
public class Test_OnAccountOwnerChangeTrigger {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    static testMethod void myUnitTest() {
        Profile p = [select id from profile where name='System Administrator'];
        //insert user1
        User user1 = new User(alias = 'test123', email='test123@pgi.com',
                              emailencodingkey='UTF-8', lastname='aslfnasf', languagelocalekey='en_US',
                              localesidkey='en_US', EmployeeNumber='12345', profileid = p.Id, country='United States',
                              timezonesidkey='America/Los_Angeles', username='asfkjnasfl@pgi.com');
        insert user1;
        
        //insert user2
        User user2 = new User(alias = 'test456', email='test456@pgi.com',
                              emailencodingkey='UTF-8', lastname='gjknasfkja', languagelocalekey='en_US',
                              localesidkey='en_US', EmployeeNumber='12345', profileid = p.Id, country='United States',
                              timezonesidkey='America/Los_Angeles', username='gdnjkdsfjkas@pgi.com');
        insert user2;
        System.runAs(user1) {
            
            //create an account
            Account acc = new Account();
            acc.Name = 'Acc-ContactRoles-asfkjnask';
            acc.BillingCountry = 'United States';
            acc.BillingCountryCode = 'US';
            acc.BillingState = 'California';
            acc.BillingStateCode = 'CA';
            acc.BillingStreet = 'Street1';
            acc.BillingPostalCode = '12345';
            acc.ownerid = user1.id;
            acc.RecordTypeID =[select Id,Name,DeveloperName from RecordType Where DeveloperName='PGi_Account'].Id;
            acc.Exclude_from_Integration__c=false;
            acc.Status__c = 'Prospect';
            insert acc;
            
            //create 2 contacts
            Contact con1 = new Contact();
            con1.FirstName = 'ContactRoles1';
            con1.LastName = 'Surname1';
            con1.AccountId = acc.Id;
            con1.ownerid = user1.id;
                    
            Contact con2 = new Contact();
            con2.FirstName = 'ContactRoles2';
            con2.LastName = 'Surname2';
            con2.AccountId = acc.Id;
            con2.ownerid = user2.id;
            insert new List<Contact>{con1, con2};
            Test.startTest();
            Opportunity o1 = PGITestUtilities.createOpportunity(acc, true);
            Lead lead1 = PGITestUtilities.getleaddetails();
            lead1.Account__c = acc.Id;
            lead1.ownerid = user1.id;
            insert lead1;
            /*
            Lead lead2 = PGITestUtilities.getleaddetails();
            lead2.Account__c = acc.Id;
            lead2.ownerid = user2.id;
            insert lead2;
            */
            acc.ownerid = user2.id;
            update acc;

            Contact con3=[select id,ownerid from contact where firstname = 'ContactRoles1'];
            Contact con4=[select id,ownerid from contact where firstname = 'ContactRoles2'];
            Lead lead3=[select id,ownerid from lead where firstname = :lead1.FirstName];
                    
            System.assertEquals(con3.OwnerId,user2.Id);
            System.assertEquals(con4.OwnerId,user2.Id);
            System.assertEquals(lead3.OwnerId,user2.Id);
            //System.assertEquals(lead2.OwnerId,user2.Id);
        }
    }
}