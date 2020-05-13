@RestResource(urlMapping = '/Contact/*')
global with sharing class ContactRest {
  @HttpPost
  global static void save(){        
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestRequest req = RestContext.request;

    SavePoint sp = Database.setSavePoint();
    try{    
      String body = req.requestBody.toString();
      Map<String, Object> bodyMap = new Map<String,Object>();  
      bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);      

      Map<String, Object> contact = (Map<String, Object>) bodyMap.get('contact');
      String accountId = (String) bodyMap.get('accountId');
      String departmentId = (String) bodyMap.get('departmentId');

      Contact c = new Contact();

      //Build a new Contact object from the incoming contact object (if there is one)
      if(c != null){
        AbstractValidator builder = new ContactRepository.builderValidator().forObject(new Contact());        
        for(String key : contact.keySet()){
          builder.set(key, contact.get(key));
        }

        c = (Contact) builder.buildAndValidate().getObject();
      }

      Account a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), accountId);
      Department__c d = departmentId == null ? null : (Department__c) RTDatabaseUtils.getEntireSObject(new Department__c(), departmentId);

      Id contactId = RTContactUtils.saveAndProvisionContact(c, d, a, true);
      
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidResponse(new AddContactData(contactId))));      
    }
    catch(Exception ex){
      Database.rollback(sp);
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
    }
  } 

  public class AddContactData{
    public String contactId;

    public AddContactData(String contactId){
      this.contactId = contactId;
    }
  }        
}