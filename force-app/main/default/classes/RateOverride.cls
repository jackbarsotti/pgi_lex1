public with sharing class RateOverride extends AbstractRepository {

  public final static String table = 'RateOverride__c';
  public final static String columns = 'id,name,chargeCode__c,customSchedule__c,customSchedule__r.baseSchedule__c,startDate__c,endDate__c,ReadyTalk_rate__c,LastModifiedBy.Name,LastModifiedDate';

  /**
   * Validations
   */      
  public class builderValidator extends AbstractValidator {  
    public boolean bypassStartNotBeforeBaseRatesStart = false;

    public builderValidator bypassStartNotBeforeBaseRatesStart(boolean b) {
      this.bypassStartNotBeforeBaseRatesStart = b;
      return this;
    }
  
    public override void validate(SObject o) {  
      RateOverride__c ro = (RateOverride__c)o;

      this.datesCannotOverlap(ro);
      this.startNotBeforeBaseRatesStart(ro);
      this.endNotBeforeStart(ro);
    }   

    public void datesCannotOverlap(RateOverride__c r){
      RateOverride rateOverrideRepo = new RateOverride();
      List<RateOverride__c> ros = rateOverrideRepo.findByCustomScheduleIdAndChargeCodeId(r.customSchedule__c, r.chargeCode__c);
      for(RateOverride__c ro : ros){
        if(r.Id == ro.Id)
          continue; 
        
        if(RTUtils.dateInRange(r.startDate__c, ro.startDate__c, ro.endDate__c, true, false))
          throw new ValidationException('Start date '+r.startDate__c.format()+' falls between existing override start/end dates.');
      }
    } 

    public void startNotBeforeBaseRatesStart(RateOverride__c r){
      if(bypassStartNotBeforeBaseRatesStart)
        return;

      Rate rateRepo = new Rate();
      List<ReadyTalk_Rate__c> rates = rateRepo.findByScheduleIdAndChargeCodeId(r.customSchedule__r.baseSchedule__c, r.chargeCode__c);

      for(ReadyTalk_Rate__c rate : rates){
        if(RTUtils.dateIsBefore(r.startDate__c, rate.startDate__c))
          throw new ValidationException('Override for '+rate.chargeCode__r.name+' '+r.startDate__c.format()+' cannot begin before base rate start date '+rate.startDate__c.format());      
      }
    }

    public void endNotBeforeStart(RateOverride__c r){
      if(r.endDate__c==null)
        return;
      if(RTUtils.dateIsBefore(r.endDate__c, r.startDate__c))
        throw new ValidationException('Cannot add rate override because the end date will be before the start date.');
    }
  } 

  /**
  * Queries
  */
  public List<RateOverride__c> findByCustomScheduleIdAndChargeCodeId(Id customScheduleId, Id chargeCodeId){
    return (List<RateOverride__c>) Database.query(selectBuilder(table,columns,'where customSchedule__c = :customScheduleId and chargeCode__c = :chargeCodeId'));
  }

  public List<RateOverride__c> findByBaseScheduleAndChargeCodeAndNullEndDateAndRateAbove(Id baseScheduleId, Id chargeCodeId, Decimal rate){
    return (List<RateOverride__c>) Database.query(selectBuilder(table,columns,'where customSchedule__r.baseSchedule__c = :baseScheduleId and chargeCode__c = :chargeCodeId and endDate__c = null and ReadyTalk_rate__c > :rate'));
  }
    
  /**
  * Helper for Save
  */
  public RateOverride__c saveRateOverride(Id chargeCodeId, Id customScheduleId, String name, Decimal rate, String startDate, String endDate) { 
    RateOverride__c rateOverride = (RateOverride__c) new RateOverride.builderValidator()
      .forObject(new RateOverride__c())
      .set('name', name)
      .set('chargeCode__c', chargeCodeId)
      .set('customSchedule__c', customScheduleId)
      .set('ReadyTalk_rate__c', rate)
      //.set('Rate__c', rate)
      .set('startDate__c', Date.parse(startDate))
      .set('endDate__c', endDate==null || endDate==''?null:Date.parse(endDate))
      .buildAndValidate()
      .save();    
    return rateOverride;
  }   

  /**
  * Helper to expire previous override
  */
  public void expirePreviousOverride(Id chargeCodeId, Id customScheduleId, String endDate){
    RateOverride repository = new RateOverride();    
    List<RateOverride__c> ros = (List<RateOverride__c>) Database.query(repository.selectBuilder(table, columns, 'where customSchedule__c =: customScheduleId and chargeCode__c = :chargeCodeId and endDate__c = null limit 1'));
    RateOverride__c latestRateOverride = null;

    if(ros.size() > 0)
      latestRateOverride = ros.get(0);

    //End the latest rate override
    if(latestRateOverride != null){
      new RateOverride.builderValidator()
      .bypassStartNotBeforeBaseRatesStart(true)
      .forObject(latestRateOverride)
      .set('endDate__c', Date.parse(endDate))
      .buildAndValidate()
      .save();           
    }    
  }
}