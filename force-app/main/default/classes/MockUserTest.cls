@isTest
public class MockUserTest {
    
    static testmethod void testMockUser(){
        
        User userObj = new User(firstname = 'testMU', 
                         lastName = 'mockuser',
                         Email = 'testmockuser@pgi.com', 
                         Username = 'test.user@pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'TestMU', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = ((Profile) Database.query('select id from profile where name=\'Standard User\'')).Id
                        ); 
        Database.insert(userObj, false);
        
        MockUser.getNewUser();
        MockUser.getSoapUser();
        new MockUser().getUser();
        System.assertEquals('Testing', MockUser.getNewUser().lastname);
        // System.assertEquals('test.user@pgi.com', new MockUser().getUser().username);
    } 
}