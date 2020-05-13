public class MockFoxDenUser {
  public static FoxDen_User__c getNewFoxDenUser() {    
    FoxDen_User__c fdu = new FoxDen_User__c(
      Name = 'Mock FoxDen User', 
      Contact__c = MockContact.getNewContact().Id,
      Email__c = 'afoobar@readytalk.com',
      Status__c = 'Pending'
    );
    Database.insert(fdu);
    return fdu;
  }
}