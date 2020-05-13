/**  
* \arg ClassName        : ParentMatchingRuleController_Test
* \arg JIRATicket       : 
* \arg CreatedOn        : 02/May/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Vijay
* \arg ModifiedBy       : 
* \arg Description      : Test class for ParentMatchingRuleController class
*/
@isTest
public class ParentMatchingRuleController_Test {
	
    static testMethod void methodAccount() {
        List<Account> accountList = new List<Account>{new Account(Name = 'United_Oil'),
		new Account(Name = 'Vijay')};
            INSERT accountList;
        
        ParentMatchingRuleController.lookup('Uni', 'Account');
		System.assertEquals('United_Oil', [SELECT Id,Name 
											FROM Account 
											WHERE Name LIKE '%Uni%'][0].Name);
    }
    
    static testMethod void methodUser() {
        List<User> users = new List<User>();
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
		User developer_support = new User(Username='dev@pgi.com', LastName='Developer', Email='dev@pgi.com', Alias='dev', CommunityNickname='dev', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',EmployeeNumber='12345', ProfileId=p.Id, LanguageLocaleKey='en_US');
		users.add(developer_support);
		INSERT users;
        
        ParentMatchingRuleController.lookup('Dev', 'User');
        
        /*System.assertEquals('Developer', [SELECT Id,LastName 
											FROM User 
                                            WHERE LastName LIKE '%Dev%'][0].LastName);*/
    }
    
}