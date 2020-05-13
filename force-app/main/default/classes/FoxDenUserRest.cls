@RestResource(urlMapping = '/FoxDenUser/*')
global with sharing class FoxDenUserRest {
  @HttpPost
  global static void save(){        
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestRequest req = RestContext.request;

    SavePoint sp = Database.setSavePoint();
    Account a = null;
    String planName = null;
    Plan planRepository = null;
    PlanAssignment planAssignmentRepository = null;
    Id foxDenUserId = null;

    try{    
      String body = req.requestBody.toString();
      Map<String, Object> bodyMap = new Map<String,Object>();  
      bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);      

      String contactId = (String) bodyMap.get('contactId');
      planName = (String) bodyMap.get('planName');
      Map<String, Object> foxdenUser = (Map<String, Object>) bodyMap.get('foxdenUser');      

      planRepository = new Plan();
      planAssignmentRepository = new PlanAssignment();
      FoxDenUser foxdenUserRepository = new FoxDenUser();      
      FoxDen_User__c fduser = new FoxDen_User__c();

      //Build a new FoxDen_User__c object from the incoming foxdenUser (if there is one)
      if(foxdenUser != null){
        AbstractValidator builder = new Subscription.builderValidator().forObject(new FoxDen_User__c());
        for(String key : foxdenUser.keySet()){
          builder.set(key, foxdenUser.get(key));
        }

        fduser = (FoxDen_User__c) builder.buildAndValidate().getObject();
      }

      //Save the FoxDen_User__c record
      Contact c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), contactId, ',Account.Status__c,Account.defaultPlan__c,Account.Id');
      a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), c.AccountId);

      //Set the contact id
      fduser.Contact__c = contactId;    
      
      Database.UpsertResult result = Database.upsert(fduser);
      if(!result.isSuccess())
        throw new ValidationException('Unable to save, please try again.');

      foxDenUserId = result.getId();
    } 
    catch(Exception ex){
      Database.rollback(sp);
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
      return;
    }

    sp = Database.setSavePoint();
    try{          
      //Save the PlanAssignment__c record
      List<Plan__c> availableAccountPlans = planRepository.getPlansByAccountIdAndName(a.Id, planName);

      if(availableAccountPlans == null || availableAccountPlans.size() < 1){
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error('No available plan named '+planName+' to assign to this access code.')})));  
        return;
      }

      planAssignmentRepository.savePlanAssignment(planName, availableAccountPlans.get(0).Id, 'FoxDen_User__c', foxDenUserId, availableAccountPlans.get(0).startDate__c, availableAccountPlans.get(0).endDate__c);

      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidResponse(new AddFoxDenUserData(foxDenUserId))));
    }
    catch(Exception ex){
      Database.rollback(sp);
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
    }
  }

  public class AddFoxDenUserData{
    public String foxdenUserId;

    public AddFoxDenUserData(String foxdenUserId){
      this.foxdenUserId = foxdenUserId;
    }
  }   
}