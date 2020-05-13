public with sharing class Plan extends AbstractRepository {

  public final static String table = 'Plan__c';
  public final static String columns = 'id,name,account__c,basePackage__c,billableType__c,endDate__c,startDate__c,isDefault__c,quantity__c,quantityStartDate__c';

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      Plan__c plan = (Plan__c)o;
      
      this.notBlank(plan.name, 'Product');
      this.startNotAfterEnd(plan.startDate__c, plan.endDate__c, Plan__c.name.getDescribe().getLabel());
      this.startNotBeforeProvisionedDate(plan);
      this.startDateNotBeforeLastInvoicedDate(plan);
      this.quantityStartDateNotBeforeLastInvoicedDate(plan);
      this.quantityStartDateNotBeforePlanStartDate(plan);
      this.planNameIsUnique(plan);
    }

    public void startNotBeforeProvisionedDate(Plan__c p){
      //If the Id is null, then we don't need to perform this check (i.e. only check on inserts, not updates)
      if(p.Id != null)
        return;

      Account a = (Account) [select id, Date_Provisioned__c,AccountNumber from Account where id =: p.account__c limit 1];

      if(a.Date_Provisioned__c == null || a.AccountNumber == null)
        throw new ValidationException('Cannot add new plan(s) before this Account is provisioned.');

      if(RTUtils.dateIsBefore(p.startDate__c, a.Date_Provisioned__c.date()))     
        throw new ValidationException('Start Date: '+p.startDate__c.format()+' cannot be before Date Provisioned: '+a.Date_Provisioned__c.format());
    }

    public void startDateNotBeforeLastInvoicedDate(Plan__c p){
      //If the Id is null, then we don't need to perform this check (i.e. only check on inserts, not updates)
      if(p.Id != null)
        return; 

      Account a = (Account) [select id, BBS_LastInvoiceDate__c from Account where id =: p.account__c limit 1];

      if(a.BBS_LastInvoiceDate__c == null)
        return;

      if(RTUtils.dateIsBefore(p.startDate__c, a.BBS_LastInvoiceDate__c))
        throw new ValidationException('Start Date: '+p.startDate__c.format()+' cannot be before Last Invoiced Date: '+a.BBS_LastInvoiceDate__c.format());
    }

    public void quantityStartDateNotBeforeLastInvoicedDate(Plan__c p){
      //If the Id is null, then we don't need to perform this check (i.e. only check on inserts, not updates)
      if(p.quantityStartDate__c == null)
        return;

      Account a = (Account) [select id, BBS_LastInvoiceDate__c from Account where id =: p.account__c limit 1];

      if(a.BBS_LastInvoiceDate__c == null)
        return;

      if(RTUtils.dateIsBefore(p.quantityStartDate__c, a.BBS_LastInvoiceDate__c))
        throw new ValidationException('Quantity Start Date: '+p.quantityStartDate__c.format()+' cannot be before Last Invoiced Date: '+a.BBS_LastInvoiceDate__c.format());
    }

    public void quantityStartDateNotBeforeplanStartDate(Plan__c p){
      //If the Id is null, then we don't need to perform this check (i.e. only check on inserts, not updates)
      if(p.quantityStartDate__c == null)
        return;

      if(RTUtils.dateIsBefore(p.quantityStartDate__c, p.startDate__c))
        throw new ValidationException('Quantity Start Date: '+p.quantityStartDate__c.format()+' cannot be before Plan Start Date: '+p.startDate__c.format());
    }

    public void planNameIsUnique(Plan__c p){
      Plan planLookup = new Plan();
      List<Plan__c> plans = planLookup.getPlansByAccountIdAndBasePackageId(p.account__c, p.basePackage__c);

      for(Plan__c plan : plans){     
        //Don't compare against the plan to be deleted
        if(plan.Id == p.Id)
          continue;

        if(plan.name == p.name)
          throw new ValidationException(plan.name+' product already exists on this account.  Product names must be unique; change the name and try again.');
      }
    }      
  }
  
  /**
   * Queries
   */  
  public List<Plan__c> getPlansByAccountId(Id accountId){
    String columnsWithRelations = columns+innerSelectBuilder('NegotiatedProducts__r', NegotiatedProduct.columns+relationBuilder('product__r', Product.columns)+',product__r.schedule__r.Name', 'order by Name')+innerSelectBuilder('PlanQuantityHistorys__r', PlanQuantityHistory.columns, 'order by Name');
    List<Plan__c> plans =  (List<Plan__c>) Database.query(selectBuilder(table,columnsWithRelations,'where Account__c =: accountId'));
    return plans;
  }

  public List<Plan__c> getPlansByAccountIdAndBillableTypeWhereAccessCodeInRange(Id accountId, String billableType, Date d){
    List<Plan__c> plans = (List<Plan__c>) Database.query(selectBuilder(table,columns,'where account__c =: accountId and billableType__c like \'%'+String.escapeSingleQuotes(billableType)+'%\' and startDate__c <= :d and (endDate__c = null or endDate__c >= :d)'));
    return plans;
  }
  
  public List<Plan__c> getPlansByAccountIdAndBillableType(Id accountId, String billableType){
    String columnsWithRelations = columns+innerSelectBuilder('NegotiatedProducts__r', NegotiatedProduct.columns+relationBuilder('product__r', Product.columns)+',product__r.schedule__r.Name', 'order by Name')+innerSelectBuilder('PlanQuantityHistorys__r', PlanQuantityHistory.columns, 'order by Name');
    List<Plan__c> plans =  (List<Plan__c>) Database.query(selectBuilder(table,columnsWithRelations,'where Account__c =: accountId and billableType__c like \'%'+String.escapeSingleQuotes(billableType)+'%\''));
    return plans;
  }  
  
  public Plan__c getById(Id planId) {
    String columnsWithRelations = columns+innerSelectBuilder('NegotiatedProducts__r', NegotiatedProduct.columns+relationBuilder('product__r', Product.columns)+',product__r.schedule__r.Name', 'order by Name') +innerSelectBuilder('PlanQuantityHistorys__r', PlanQuantityHistory.columns, 'order by Name');
    Plan__c plan = (Plan__c) Database.query(selectBuilder(table,columnsWithRelations,'where id =: planId limit 1'));
    return plan;
  }
  
  //SFB-2343: When accessCode__r.inactive__c is a blank value the evaluation "= false" IS NOT true, therefore, we can AND the values to provide what we need.
  // the same applies for FoxDen_User__r.inactive__c
  public Integer getActiveAccessCodes(Id planId) {
  	return (Integer) [select count() from PlanAssignment__c where plan__c = :planId and (accessCode__r.inactive__c = false and FoxDen_User__r.inactive__c = false and S3User__r.inactive__c = false) and (startDate__c <= TODAY) and (endDate__c = null OR endDate__c > TODAY)];
  }

  public List<Plan__c> getPlansByAccountIdAndBasePackageId(Id accountId, Id basePackageId){
    List<Plan__c> plans = (List<Plan__c>) Database.query(selectBuilder(table,columns,'where account__c =: accountId and basePackage__c =: basePackageId'));
    return plans;
  }

  public List<Plan__c> getPlansByAccountIdAndName(Id accountId, String name){
    List<Plan__c> plans = (List<Plan__c>) Database.query(selectBuilder(table,columns,'where account__c =: accountId and name =: name and (endDate__c = null or endDate__c >= TODAY)'));
    return plans;
  }

  public List<Plan__c> getPlansByAccountIdAndIsDefault(Id accountId){
    List<Plan__c> plans = (List<Plan__c>) Database.query(selectBuilder(table,columns,'where account__c =: accountId and isDefault__c = true and (endDate__c = null or endDate__c >= TODAY)'));
    return plans;
  }
  
  /**
   * Helper for Save
   */
  public Plan__c savePlan(String name, Id accountId, Id packageId, String billableType, String startDate, String endDate, String quantity, String quantityStartDate) {
    Plan__c plan = (Plan__c) new Plan.builderValidator()
      .forObject(new Plan__c())
      .set('name', name)
      .set('account__c', accountId)
      .set('basePackage__c', packageId)
      .set('billableType__c', billableType)
      .set('startDate__c', startDate==''? null : Date.parse(startDate))
      .set('endDate__c', endDate==null||endDate=='' ? null : Date.parse(endDate))
      .set('quantity__c', quantity==null||quantity=='' ? null : Integer.valueOf(quantity))
      .set('quantityStartDate__c', quantityStartDate==null||quantityStartDate=='' ? null : Date.parse(quantityStartDate))
      .buildAndValidate()
      .save();    
    return plan;
  }  
}