public with sharing class Schedule extends AbstractRepository {

  public final static String table = 'Schedule__c';
  public final static String columns = 'id,name,description__c,scheduleType__c,objectId__c';   
  
  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      Schedule__c schedule = (Schedule__c)o;
      
    }        
  } 
  
  /**
   * Queries
   */
  public List<Schedule__c> findAllSchedules(){
    return (List<Schedule__c>) Database.query(selectBuilder(table,columns,'order by name'));
  }

  public List<Schedule__c> findAllSchedulesByType(String type){
    return (List<Schedule__c>) Database.query(selectBuilder(table,columns,'where scheduleType__c = :type order by name desc'));
  }
  
  public Schedule__c findById(Id id) {
    String columnsWithRelations = columns+innerSelectBuilder('ReadyTalk_Rates__r', Rate.columns+relationBuilder('chargeCode__r', ChargeCode.columns)+',chargeCode__r.chargeCodeType__r.Name', 'order by chargeCode__r.description__c, chargeCode__r.chargeCodeType__c');
    List<Schedule__c> schedules = Database.query(selectBuilder(table,columnsWithRelations,'where id = :id'));
    if(schedules.size() > 0)
      return schedules.get(0);
    else
      return null;
  }

  public Schedule__c findByIdAndRateChargeCodeType(Id id, List<String> chargeCodeTypes){    
    String columnsWithRelations = columns+innerSelectBuilder('ReadyTalk_Rates__r', Rate.columns+relationBuilder('chargeCode__r', ChargeCode.columns)+',chargeCode__r.chargeCodeType__r.Name', 'where chargeCode__r.chargeCodeType__r.Name in :chargeCodeTypes order by chargeCode__r.description__c, chargeCode__r.chargeCodeType__c');
    List<Schedule__c> schedules = Database.query(selectBuilder(table,columnsWithRelations,'where id = :id'));
    if(schedules.size() > 0)
      return schedules.get(0);
    else
      return null;    
  }

  /**
   * Helper for save
   */
  public Schedule__c saveSchedule(String name, String description, String scheduleType, Double objectId) {
    Schedule__c s = (Schedule__c) new Schedule.builderValidator()
      .forObject(new Schedule__c())
      .set('name', name)
      .set('description__c', description)
      .set('scheduleType__c', scheduleType)
      .set('objectId__c', objectId)
      .buildAndValidate()
      .save();    
    return s;
  }
}