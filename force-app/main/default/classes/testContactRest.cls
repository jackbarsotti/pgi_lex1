@isTest
private class testContactRest {
 @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
  private static RestRequest req = new RestRequest(); 
  private static RestResponse res = new RestResponse();        
  private static Account a = MockAccount.getNewAccount();    

  static{
    req.requestBody = Blob.valueOf('{"contact": {"FirstName": "Bob", "LastName": "Smith", "Email": "bob.smith@ecovate.com", "Phone": "303-209-1756"}, "accountId": "'+a.Id+'"}'); 
    RestContext.request = req; RestContext.response = res;
  }    
	
	@isTest static void test_construct_ContactRest() {
		ContactRest c = new ContactRest();
    System.assert(c != null);
	}
	
	@isTest static void test_save_with_valid_data() {
    ContactRest.save();    
    String response = RestContext.response.responseBody.toString();
    System.debug(response);
    System.assert(!response.contains('error'));		
	}

  @isTest static void test_save_with_invalid_data() {
    req.requestBody = Blob.valueOf('{"contact": {"FirstName": "Bob", "LastName": "Smith", "Email": "bob.smith@ecovate.com", "Phone": "303-209-1756"}, "accountId": "1234"}'); 
    ContactRest.save(); 
    String response = RestContext.response.responseBody.toString();
    System.debug(response);
    System.assert(response.contains('error'));    
  }
}