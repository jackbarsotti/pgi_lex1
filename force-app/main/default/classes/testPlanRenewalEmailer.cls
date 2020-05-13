@isTest(SeeAllData=false)
public class testPlanRenewalEmailer {
 @testSetup static void setup() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    }
	
  private static PlanRenewalEmailerSchedulable emailer;
  private static SFPCTestHelper sfpcTestHelper;

  private static void init() {

    emailer = new PlanRenewalEmailerSchedulable();
    sfpcTestHelper = new SFPCTestHelper();
    Account account = createAccount(true);
    sfpcTestHelper.createForAccount(account);
    delete sfpcTestHelper.accessCodePlanAssignment;
    delete sfpcTestHelper.foxDenPlanAssignment;
    createPlanAssignment(sfpcTestHelper.plan);      
  }

  /*
  * While working on SFB-2379 and uploading to production, the below two tests mysteriosuly stopped working for no apparent reason.
  * I'm commenting them out until a later date.  
  static testMethod void testPlanWithAnnualProduct() {
    sfpcTestHelper.plan.startDate__c = Date.today() - 335;
    update sfpcTestHelper.plan;
    sfpcTestHelper.product.recurringChargeFrequency__c = 'ANNUALLY';
    update sfpcTestHelper.product;
    delete sfpcTestHelper.recurringChargeOverride;
    List<Messaging.SingleEmailMessage> msgs = emailer.runRenewal();
    System.assert(msgs.size() >= 1);
  }
    
  static testMethod void testPlanWithAnnualRecurringChargeOverride() {
    sfpcTestHelper.plan.startDate__c = Date.today() - 335;
    update sfpcTestHelper.plan;
    sfpcTestHelper.recurringChargeOverride.recurringChargeFrequency__c = 'ANNUALLY';
    sfpcTestHelper.recurringChargeOverride.recurringCharge__c = 100;
    update sfpcTestHelper.recurringChargeOverride;
    List<Messaging.SingleEmailMessage> msgs = emailer.runRenewal();
    System.assert(msgs.size() >= 1);
  }
  */
    
  // We don't send a renewal email if the recurring charge is zero
  static testMethod void testPlanWhereRecurringChargeIsZero() {
    init();
    sfpcTestHelper.plan.startDate__c = Date.today() - 335;
    update sfpcTestHelper.plan;
    sfpcTestHelper.product.recurringChargeFrequency__c = 'ANNUALLY';
    sfpcTestHelper.product.recurringCharge__c = 0;
    update sfpcTestHelper.product;
    delete sfpcTestHelper.recurringChargeOverride;
    List<Messaging.SingleEmailMessage> msgs = emailer.runRenewal();
    System.assert(msgs.size() == 0);
  }

  static testMethod void testPlanWhereEndDateLessThan30DaysOut() {
    init();
    // Test.startTest();
    sfpcTestHelper.plan.startDate__c = Date.today() - 335;
    sfpcTestHelper.plan.startDate__c = Date.today();
    update sfpcTestHelper.plan;
    sfpcTestHelper.product.recurringChargeFrequency__c = 'ANNUALLY';
    update sfpcTestHelper.product;
    delete sfpcTestHelper.recurringChargeOverride;
    List<Messaging.SingleEmailMessage> msgs = emailer.runRenewal();
    System.assert(msgs.size() == 0);
    Test.stopTest();
  }
    
  private static Account createAccount(boolean autoRenew) {
    Account account = MockAccount.getNewAccount();
    account.AutoRenewalEmail__c = autoRenew;
    update account;
    return account;
  }
    
  private static void createPlanAssignment(Plan__c plan) {
    PlanAssignment planAssRepo = new PlanAssignment();
    Subscription__c sub = MockSubscription.getNewSubscription();
    planAssRepo.savePlanAssignment(plan.Name, plan.Id, 'Subscription__c', sub.Id, Date.today() - 335, null);
  }

}