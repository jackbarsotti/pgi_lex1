public with sharing class ScheduleOverride extends AbstractRepository {

  public final static String table = 'ScheduleOverride__c';
  public final static String columns = 'id,name,customSchedule__c,endDate__c,negotiatedProduct__c,scheduleName__c,standardSchedule__c,startDate__c,LastModifiedDate,LastModifiedBy.Name';  
  
  /**
   * Validations
   */
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      ScheduleOverride__c so = (ScheduleOverride__c)o;
      
      this.notBlank(so.name, ScheduleOverride__c.name.getDescribe().getLabel());
      this.datesCannotOverlap(so);
      this.startNotBeforePlanStart(so);
      this.startNotAfterPlanEnd(so);      
      this.startNotAfterEnd(so.startDate__c, so.endDate__c, 'Schedule Override');      
    }  

    public void datesCannotOverlap(ScheduleOverride__c so){
      ScheduleOverride soRepository = new ScheduleOverride();
      List<ScheduleOverride__c> scheduleOverrides = soRepository.findByNegotiatedProductIdAndScheduleIdOrCustomScheduleId(so.negotiatedProduct__c, so.standardSchedule__c, so.customSchedule__c);

      for(ScheduleOverride__c scheduleOverride : scheduleOverrides){
        if(RTUtils.dateInRange(so.startDate__c, scheduleOverride.startDate__c, scheduleOverride.endDate__c, false, false))
          throw new ValidationException('Schedule Override Overlaps with existing record, please check Start Date and try again');
      }
    } 

    public void startNotBeforePlanStart(ScheduleOverride__c so){
      NegotiatedProduct npRepository = new NegotiatedProduct();
      NegotiatedProduct__c np = npRepository.getById(so.negotiatedProduct__c);

      if(RTUtils.dateIsBefore(so.startDate__c, np.plan__r.startDate__c))
        throw new ValidationException('Schedule Override cannot begin before Product start date');
    } 

    public void startNotAfterPlanEnd(ScheduleOverride__c so){
      NegotiatedProduct npRepository = new NegotiatedProduct();
      NegotiatedProduct__c np = npRepository.getById(so.negotiatedProduct__c);

      if(np.plan__r.endDate__c == null)
        return;      

      if(RTUtils.dateIsBefore(np.plan__r.endDate__c, so.startDate__c))
        throw new ValidationException('Schedule Override cannot begin after Product end date');
    }          
  } 

  /**
   * Queries
   */
  public List<ScheduleOverride__c> findByAccountId(Id accountId) {
      String columnsWithRelations = columns+relationBuilder('customSchedule__r', CustomSchedule.columns)+relationBuilder('standardSchedule__r', Schedule.columns);
     List<ScheduleOverride__c> soList = Database.query(selectBuilder(table,columnsWithRelations,'where NegotiatedProduct__r.Account__r.Id = :accountId order by startDate__c desc'));
     return soList;    
  }

  public ScheduleOverride__c findByNegotiatedProductIdAndInRange(Id id, Date d){
    String columnsWithRelations = columns+relationBuilder('customSchedule__r', CustomSchedule.columns)+relationBuilder('standardSchedule__r', Schedule.columns);
    List<ScheduleOverride__c> sList = Database.query(selectBuilder(table,columnsWithRelations,'where negotiatedProduct__c = :id and startDate__c <= :d and (endDate__c = null or endDate__c > :d) order by startDate__c desc limit 1'));
    if(sList.size()>0)
      return sList.get(0);
    else
      return null;
  } 
  
  public List<ScheduleOverride__c> findByNegotiatedProductId(Id id){
    List<ScheduleOverride__c> sList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id order by startDate__c desc'));
    return sList;    
  }
  
  public List<ScheduleOverride__c> findByNegotiatedProductIdAndIsFuture(Id id){
    List<ScheduleOverride__c> sList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :id and startDate__c > :Date.today()'));
    return sList;    
  }  

  public List<ScheduleOverride__c> findByNegotiatedProductIdAndScheduleIdOrCustomScheduleId(Id negotiatedProductId, Id scheduleId, Id customScheduleId){
    List<ScheduleOverride__c> sList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c =: negotiatedProductId and (standardSchedule__c =: scheduleId or customSchedule__c =: customScheduleId)'));
    return sList;
  }
  
  /**
   * Helper for save
   */
  public ScheduleOverride__c saveScheduleOverride(String name, Id negotiatedProductId, Id scheduleId, Id customScheduleId, String startDate, String endDate) {
    ScheduleOverride__c so = (ScheduleOverride__c) new ScheduleOverride.builderValidator()
      .forObject(new ScheduleOverride__c())
      .set('name', name)
      .set('negotiatedProduct__c', negotiatedProductId)
      .set('standardSchedule__c', scheduleId)
      .set('customSchedule__c', customScheduleId)
      .set('startDate__c', startDate==''? null : Date.parse(startDate))
      .set('endDate__c', endDate==null || endDate=='' ? null : Date.parse(endDate))
      .buildAndValidate()
      .save();  
    return so;
  }  
  
  /**
   * Helper to expire previous override
   */
  public void expirePreviousOverride(Id negotiatedProductId, String endDate) {
    List<ScheduleOverride__c> soList = Database.query(selectBuilder(table,columns,'where negotiatedProduct__c = :negotiatedProductId and endDate__c = null limit 1'));     
    
    if(soList.size()<=0)
      return;

    ScheduleOverride__c o = soList.get(0);      
    
    ScheduleOverride__c so = (ScheduleOverride__c) new ScheduleOverride.builderValidator()
      .forObject(o)
      .set('endDate__c', endDate==''? null : Date.parse(endDate))
      .buildAndValidate()
      .save();    
  }
  
}