global with sharing class PlanRenewalEmailerSchedulable implements Schedulable {
    
  global void execute(SchedulableContext context) {
    runRenewal();
  }    
      
  public List<Messaging.SingleEmailMessage> runRenewal() {
    System.debug('runRenewal method called');
    List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
    List<Plan__c> plans = getAnnualAccessCodePlansDueForRenewal(getAutoRenewalAccounts());
    List<PlanAssignment__c> planAssignments = getActiveContactsByPlan(plans);
    EmailTemplate template = [SELECT id from EmailTemplate where developerName = 'Subscription_Renewal'];
    for (PlanAssignment__c planAss : planAssignments) {
      Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
      msg.setTemplateId(template.Id);
      msg.setTargetObjectId(planAss.accessCode__r.Contact__c);
      msg.setSenderDisplayName('ReadyTalk Provisioning');
      msg.setWhatId(planAss.plan__r.Id);
      msg.setUseSignature(false);
      msg.setReplyTo('noreply@pgi.com');
      msgList.add(msg);
    }
    Messaging.sendEmail(msgList, true);
    return msgList;
  }
    
  private List<Plan__c> getAnnualAccessCodePlansDueForRenewal(List<String> accountIds) {
    List<Plan__c> plans = [select Id, name, (select Id, name, product__r.recurringChargeFrequency__c, product__r.recurringCharge__c from NegotiatedProducts__r) 
      from Plan__c where billableType__c = 'ACCESS_CODE' and startDate__c < TODAY
      and DAY_IN_YEAR(startDate__c) = :Date.today().addDays(30).dayOfYear()
      and (endDate__c = null or endDate__c > :Date.today().addDays(30))
      and account__r.Id in :accountIds];
      
    Map<String, RecurringChargeOverride__c> rcoMap = getRecurringChargeOverrides();
    List<Plan__c> validPlans = new List<Plan__c>();
    for (Plan__c plan : plans) {
      System.debug('plan name = ' + plan.Name);
      for (NegotiatedProduct__c np : plan.NegotiatedProducts__r) {
        System.debug('np.name = ' + np.Name);
        System.debug('np.product__r.recurringChargeFrequency__c = ' +  np.product__r.recurringChargeFrequency__c + ' ' + np.product__r.Id);
        if (rcoMap.containsKey(np.Id)) {
          System.debug('np.Id has rco');
          if (rcoMap.get(np.Id).recurringChargeFrequency__c == 'ANNUALLY' && rcoMap.get(np.Id).recurringCharge__c > 0) {
            System.debug('Plan rco frequency is annual and charge is > 0');
            validPlans.add(plan);
          }
          continue;
        }
        if (np.product__r.recurringChargeFrequency__c == 'ANNUALLY' && np.product__r.recurringCharge__c > 0) {
          System.debug('Plan is annual and charge is > 0');
          validPlans.add(plan);
          continue;
        }
      }
    }
    return validPlans;
  }

  private Map<String, RecurringChargeOverride__c> getRecurringChargeOverrides() {
    Map<String, RecurringChargeOverride__c> rcoMap = new Map<String, RecurringChargeOverride__c>();
    List<RecurringChargeOverride__c> overrides = (List<RecurringChargeOverride__c>) Database.query('select Id, negotiatedProduct__r.Id, recurringCharge__c, recurringChargeFrequency__c from RecurringChargeOverride__c');
    for (RecurringChargeOverride__c rco : overrides) {
      rcoMap.put(rco.negotiatedProduct__r.Id, rco);
    }
    return rcoMap;
  }
    
  private List<String> getAutoRenewalAccounts() {
    List<String> accountIds = new List<String>();
    List<Account> accounts = [select id from Account where AutoRenewalEmail__c = true];
    for (Account account : accounts) {
      System.debug('account with sfId: ' + account.Id + ' is on Auto Renewal');
      accountIds.add(account.Id);
    }
    return accountIds;
  }
  
  private List<PlanAssignment__c> getActiveContactsByPlan(List<Plan__c> plans) {
    List<String> planIds = new List<String>();
    for (Plan__c plan : plans) {
      planIds.add(plan.Id);
    }
    List<PlanAssignment__c> planAssignments = [SELECT Id, accessCode__r.inactive__c, accessCode__r.Contact__c, plan__r.Id FROM PlanAssignment__c 
      where (endDate__c = null OR endDate__c > :Date.today().addDays(30)) and accessCode__r.inactive__c = false and Plan__c in :planIds];
    return planAssignments;
  }
}