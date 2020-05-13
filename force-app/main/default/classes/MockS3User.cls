public class MockS3User {
  public static S3User__c getNewS3User() {    
    S3User__c s3u = new S3User__c(
      Name = 'Mock S3 User', 
      Contact__c = MockContact.getNewContact().Id,
      Email__c = 'afoobar@readytalk.com',
      Status__c = 'Pending'
    );
    Database.insert(s3u);
    return s3u;
  }
}