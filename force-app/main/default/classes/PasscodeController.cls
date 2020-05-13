global with sharing class PasscodeController {  
  private static final String SYNC_PASSCODE_ENDPOINT = 'https://provision.ecovate.com/bbs-provisioning/rest/accessCode/syncPasscode';
  private final Id subscriptionId;
  private static final Subscription subscriptionRepo = new Subscription();
  
  public PasscodeController(ApexPages.StandardController controller) {
    Subscription__c s = (Subscription__c)controller.getRecord();    

    if(s!=null)
      this.subscriptionId = s.id;
    else
      this.subscriptionId = ApexPages.currentPage().getParameters().get('id');
  }

  /**
  * Remote action to call out to the syncPasscode endpoint
  */
  @RemoteAction
  global static Map<String, Object> getPasscode(String subscriptionId) {
    Subscription__c s = subscriptionRepo.findById(subscriptionId);

    if(s==null)
      throw new ValidationException('Inavlid Access Code');

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(SYNC_PASSCODE_ENDPOINT+'?tf='+s.Contact_Toll_Free_Number__c+'&ac='+s.Name);
    req.setMethod('GET'); 

    HttpResponse res = h.send(req);
    return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
  }
      
  public Id getSubscriptionId() {
    return this.subscriptionId;
  }
    
}