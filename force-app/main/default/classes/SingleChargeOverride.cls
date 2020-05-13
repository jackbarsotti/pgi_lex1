public with sharing class SingleChargeOverride extends AbstractRepository {

  public final static String table = 'SingleChargeOverride__c';
  public final static String columns = 'id,name,baseProductSingleCharge__c,endDate__c,negotiatedProduct__c,singleCharge__c,startDate__c,LastModifiedDate';    
  
  /**
   * Validations
   */  
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      SingleChargeOverride__c sco = (SingleChargeOverride__c)o;
      
      this.notBlank(sco.name, SingleChargeOverride__c.name.getDescribe().getLabel());
    }        
  } 
  
  /**
   * Queries
   */
  public List<SingleChargeOverride__c> findByAccountId(Id accountId) {
     List<SingleChargeOverride__c> scoList = Database.query(selectBuilder(table,columns,'where NegotiatedProduct__r.Account__r.Id = :accountId order by startDate__c desc'));
     return scoList;    
  }

  public SingleChargeOverride__c findByNegotiatedProductIdAndInRange(Id id, Date d){
    List<SingleChargeOverride__c> scoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id and startDate__c <= :d and (endDate__c = null or endDate__c > :d) order by startDate__c desc limit 1'));
    if(scoList.size()>0)
      return scoList.get(0);
    else
      return null;
  }
  
  public List<SingleChargeOverride__c> findByNegotiatedProductId(Id id){
    List<SingleChargeOverride__c> scoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id order by startDate__c desc'));
    return scoList;    
  }
  
  public List<SingleChargeOverride__c> findByNegotiatedProductIdAndIsFuture(Id id){
    List<SingleChargeOverride__c> scoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id and startDate__c > :Date.today()'));
    return scoList;    
  }  
  
  /**
   * Helper for Save Single Charge Override
   */
  public SingleChargeOverride__c saveSingleChargeOverride(String name, Decimal baseSingleCharge, Id negotiatedProductId, Decimal singleCharge, String startDate, String endDate) {        
    SingleChargeOverride__c sco = (SingleChargeOverride__c) new SingleChargeOverride.builderValidator()
      .forObject(new SingleChargeOverride__c())
      .set('name', name)
      .set('baseProductSingleCharge__c', baseSingleCharge==null ? 0.0000 : baseSingleCharge)
      .set('negotiatedProduct__c', negotiatedProductId)
      .set('singleCharge__c', singleCharge==null ? 0.0000 : singleCharge)
      .set('startDate__c', startDate==''? null : Date.parse(startDate))
      .set('endDate__c', endDate==null || endDate=='' ? null : Date.parse(endDate))
      .buildAndValidate()
      .save();
    return sco;    
  }
  
  /**
   * Helper to expire previous override
   */
  public void expirePreviousOverride(Id negotiatedProductId, String endDate) {
    List<SingleChargeOverride__c> scoList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :negotiatedProductId and endDate__c = null limit 1'));     
    
    if(scoList.size()<=0)
      return;

    SingleChargeOverride__c o = scoList.get(0);      
    
    SingleChargeOverride__c sco = (SingleChargeOverride__c) new SingleChargeOverride.builderValidator()
      .forObject(o)
      .set('endDate__c', endDate==''? null : Date.parse(endDate))
      .buildAndValidate()
    .save();    
  }
}