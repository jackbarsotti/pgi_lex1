public with sharing class Rate extends AbstractRepository {

  public final static String table = 'ReadyTalk_Rate__c';
  public final static String columns = 'id,name,chargeCode__c,endDate__c,ReadyTalk_Rate__c,schedule__c,startDate__c,objectId__c';   
  
  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      ReadyTalk_Rate__c rate = (ReadyTalk_Rate__c)o;
      
    }        
  } 
  
  /**
   * Queries
   */
  public ReadyTalk_Rate__c findById(Id rateId){
    return (ReadyTalk_Rate__c) Database.query(selectBuilder(table, columns+',chargeCode__r.name', 'where id = :rateId'));
  }

  public List<ReadyTalk_Rate__c> findByScheduleIdAndChargeCodeId(Id scheduleId, Id chargeCodeId){
    return (List<ReadyTalk_Rate__c>) Database.query(selectBuilder(table,columns+',chargeCode__r.name','where schedule__c = :scheduleId and chargeCode__c = :chargeCodeId'));
  }

  /**
  * Helper for Save
  */
  public ReadyTalk_Rate__c saveRate(String name, Id chargeCodeId, String startDate, Decimal rate, Id scheduleId, String endDate, Double objectId) { 
    ReadyTalk_Rate__c r = (ReadyTalk_Rate__c) new Rate.builderValidator()
      .forObject(new ReadyTalk_Rate__c())
      .set('name', name)
      .set('chargeCode__c', chargeCodeId)
      .set('startDate__c', Date.parse(startDate))
      .set('ReadyTalk_rate__c', rate)
      .set('schedule__c', scheduleId)
      .set('endDate__c', endDate==null || endDate==''?null:Date.parse(endDate))
      .set('objectId__c', objectId)
      .buildAndValidate()
      .save();    
    return r;
  }  

  /**
  * Helper to expire previous rate
  */
  public void expirePreviousRate(Id chargeCodeId, Id scheduleId, String endDate){
    Rate repository = new Rate();    
    List<ReadyTalk_Rate__c> rates = (List<ReadyTalk_Rate__c>) Database.query(repository.selectBuilder(table, columns, 'where schedule__c = :scheduleId and chargeCode__c = :chargeCodeId and endDate__c = null limit 1'));
    ReadyTalk_Rate__c latestRate = null;

    if(rates.size() > 0)
      latestRate = rates.get(0);

    //End the latest rate override
    if(latestRate != null){
      new Rate.builderValidator()
      .forObject(latestRate)
      .set('endDate__c', Date.parse(endDate))
      .buildAndValidate()
      .save();           
    }    
  }
}