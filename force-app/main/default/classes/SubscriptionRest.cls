@RestResource(urlMapping = '/Subscription/*')
global with sharing class SubscriptionRest{            

  @HttpPost
  global static void save(){        
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestRequest req = RestContext.request;

    SavePoint sp = Database.setSavePoint();
    Account a = null;
    String planName = null;
    Plan planRepository = null;
    PlanAssignment planAssignmentRepository = null;
    Id subscriptionId = null;

    try{    
      String body = req.requestBody.toString();
      Map<String, Object> bodyMap = new Map<String,Object>();  
      bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);      

      String contactId = (String) bodyMap.get('contactId');
      planName = (String) bodyMap.get('planName');
      Map<String, Object> accessCode = (Map<String, Object>) bodyMap.get('accessCode');      

      planRepository = new Plan();
      planAssignmentRepository = new PlanAssignment();
      Subscription subscriptionRepository = new Subscription();      
      Subscription__c sub = new Subscription__c();

      //Build a new Subscription__c object from the incoming accessCode (if there is one)
      if(accessCode != null){
        AbstractValidator builder = new Subscription.builderValidator().forObject(new Subscription__c());
        for(String key : accessCode.keySet()){
          builder.set(key, accessCode.get(key));
        }

        sub = (Subscription__c) builder.buildAndValidate().getObject();
      }

      //Save the Subscription__c record
      Contact c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), contactId, ',Account.Status__c,Account.defaultPlan__c,Account.Id');
      a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), c.AccountId);    
      subscriptionId = RTAccessCodeUtils.saveAndProvisionSubscription(sub, c, a, true);
    }  
    catch(Exception ex){
      Database.rollback(sp);
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
      return;
    }

    sp = Database.setSavePoint();
    try{    
      //Save the PlanAssignment__c record
      List<Plan__c> availableAccountPlans = new List<Plan__c>();
      if(planName != null)
        availableAccountPlans = planRepository.getPlansByAccountIdAndName(a.Id, planName);
      else
        availableAccountPlans = planRepository.getPlansByAccountIdAndIsDefault(a.Id);

      if(availableAccountPlans == null || availableAccountPlans.size() < 1){
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error('No available plan to assign to this access code.')})));  
        return;
      }

      planAssignmentRepository.savePlanAssignment(availableAccountPlans.get(0).Name, availableAccountPlans.get(0).Id, 'Subscription__c', subscriptionId, Date.today(), availableAccountPlans.get(0).endDate__c);

      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidResponse(new AddSubscriptionData(subscriptionId))));
    }
    catch(Exception ex){
      Database.rollback(sp);
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
    }
  }

  public class AddSubscriptionData{
    public String subscriptionId;

    public AddSubscriptionData(String subscriptionId){
      this.subscriptionId = subscriptionId;
    }
  }   
}