public with sharing class RecurringChargeOverride extends AbstractRepository {

  public final static String table = 'RecurringChargeOverride__c';
  public final static String columns = 'id,name,baseProductRecurringCharge__c,endDate__c,negotiatedProduct__c,recurringCharge__c,recurringChargeFrequency__c,startDate__c,LastModifiedDate,LastModifiedBy.Name';   
  
  /**
   * Validations
   */
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      RecurringChargeOverride__c rco = (RecurringChargeOverride__c)o;
      
      this.notBlank(rco.name, RecurringChargeOverride__c.name.getDescribe().getLabel());
      this.notBlank(rco.recurringChargeFrequency__c, 'Frequency');
      this.datesCannotOverlap(rco);
      this.startNotBeforePlanStart(rco);
      this.startNotAfterPlanEnd(rco);
      this.startNotAfterEnd(rco.startDate__c, rco.endDate__c, 'Recurring Charge Override');      
    }  

    public void datesCannotOverlap(RecurringChargeOverride__c rco){
      RecurringChargeOverride rcoRepository = new RecurringChargeOverride();
      List<RecurringChargeOverride__c> rcos = rcoRepository.findByNegotiatedProductId(rco.negotiatedProduct__c);

      for(RecurringChargeOverride__c o : rcos){
        if(RTUtils.dateInRange(rco.startDate__c, o.startDate__c, o.endDate__c, false, false))
          throw new ValidationException('Recurring Charge Override Overlaps with existing record, please check Start Date and try again');
      }
    } 

    public void startNotBeforePlanStart(RecurringChargeOverride__c rco){
      NegotiatedProduct npRepository = new NegotiatedProduct();
      NegotiatedProduct__c np = npRepository.getById(rco.negotiatedProduct__c);

      if(RTUtils.dateIsBefore(rco.startDate__c, np.plan__r.startDate__c))
        throw new ValidationException('Recurring Charge Override cannot begin before Product start date');
    }   

    public void startNotAfterPlanEnd(RecurringChargeOverride__c rco){
      NegotiatedProduct npRepository = new NegotiatedProduct();
      NegotiatedProduct__c np = npRepository.getById(rco.negotiatedProduct__c);

      if(np.plan__r.endDate__c == null)
        return;

      if(RTUtils.dateIsBefore(np.plan__r.endDate__c, rco.startDate__c))
        throw new ValidationException('Recurring Charge Override cannot begin after Product end date');      
    }        
  } 
  
  /**
   * Queries
   */
  public List<RecurringChargeOverride__c> findByAccountId(Id accountId){
    List<RecurringChargeOverride__c> rcoList = Database.query(selectBuilder(table,columns,'where NegotiatedProduct__r.Account__r.Id = :accountId order by startDate__c desc'));
    return rcoList;
  }

  public RecurringChargeOverride__c findByNegotiatedProductIdAndInRange(Id id, Date d){
    List<RecurringChargeOverride__c> rcoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id and startDate__c <= :d and (endDate__c = null or endDate__c > :d) order by startDate__c desc limit 1'));
    if(rcoList.size()>0)
      return rcoList.get(0);
    else
      return null;
  }  
  
  public List<RecurringChargeOverride__c> findByNegotiatedProductId(Id id){
    List<RecurringChargeOverride__c> rcoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id order by startDate__c desc'));
    return rcoList;    
  }
  
  public List<RecurringChargeOverride__c> findByNegotiatedProductIdAndIsFuture(Id id){
    List<RecurringChargeOverride__c> rcoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id and startDate__c > :Date.today()'));
    return rcoList;    
  }
  
  /**
   * Helper for save
   */
  public RecurringChargeOverride__c saveRecurringChargeOverride(String name, Decimal baseRecurringCharge, Id negotiatedProductId, Decimal recurringCharge, String recurringChargeFrequency, String startDate, String endDate) {
    RecurringChargeOverride__c rco = (RecurringChargeOverride__c) new RecurringChargeOverride.builderValidator()
      .forObject(new RecurringChargeOverride__c())
      .set('name', name)
      .set('baseProductRecurringCharge__c', baseRecurringCharge==null ? 0.0000 : baseRecurringCharge)
      .set('negotiatedProduct__c', negotiatedProductId)
      .set('recurringCharge__c',recurringCharge==null ? 0.0000 : recurringCharge)
      .set('recurringChargeFrequency__c', recurringChargeFrequency)
      .set('startDate__c', startDate==''? null : Date.parse(startDate))
      .set('endDate__c', endDate==null || endDate=='' ? null : Date.parse(endDate))
      .buildAndValidate()
      .save();
    return rco;    
  }  
  
  /**
   * Helper to expire previous override
   */
  public void expirePreviousOverride(Id negotiatedProductId, String endDate) {
    List<RecurringChargeOverride__c> rcoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :negotiatedProductId and endDate__c = null limit 1'));     
    
    if(rcoList.size()<=0)
      return;

    RecurringChargeOverride__c o = rcoList.get(0);      
    
    RecurringChargeOverride__c rco = (RecurringChargeOverride__c) new RecurringChargeOverride.builderValidator()
      .forObject(o)
      .set('endDate__c', endDate==''? null : Date.parse(endDate))
      .buildAndValidate()
    .save();    
  }
  
}