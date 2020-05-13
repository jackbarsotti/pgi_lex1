public with sharing class CustomSchedule extends AbstractRepository {

  public final static String table = 'CustomSchedule__c';
  public final static String columns = 'id,name,account__c,baseSchedule__c,description__c,isDefault__c,baseScheduleType__c';

  /**
   * Validations
   */      
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      CustomSchedule__c cs = (CustomSchedule__c)o;
      this.notBlank(cs.name, 'Custom Schedule Name');
      this.uniqueName(cs);
    }        

    public void uniqueName(CustomSchedule__c cs){
      CustomSchedule csRepo = new CustomSchedule();
      List<CustomSchedule__c> customSchedules = csRepo.findByAccountId(cs.account__c);

      for(CustomSchedule__c o : customSchedules){
        //Don't compare against the custom schedule provided
        if(cs.id != null && cs.id == o.id)
          continue;

        if(o.name.equals(cs.name)){
          throw new ValidationException('A Custom Schedule named '+cs.name+' already exists under this Account.');
        }
      }
    }
  } 

  /**
   * Queries
   */
  public List<CustomSchedule__c> findByAccountId(Id accountId){
    String columnsWithRelations = columns+innerSelectBuilder('RateOverrides__r', RateOverride.columns, 'order by CreatedDate desc')+',Account__r.id,Account__r.name,Account__r.accountNumber,BaseSchedule__r.name,BaseSchedule__r.scheduleType__c';
    return (List<CustomSchedule__c>)  Database.query(selectBuilder(table,columnsWithRelations,'where account__c =: accountId order by BaseSchedule__r.scheduleType__c, Name'));
  }

  public List<CustomSchedule__c> findByAccountIdOrParentAccountId(Id accountId, Id parentAccountId){
    String columnsWithRelations = columns+innerSelectBuilder('RateOverrides__r', RateOverride.columns, 'order by CreatedDate desc')+',Account__r.id,Account__r.name,Account__r.accountNumber,BaseSchedule__r.name,BaseSchedule__r.scheduleType__c';
    return (List<CustomSchedule__c>)  Database.query(selectBuilder(table,columnsWithRelations,'where account__c =: accountId or account__c =: parentAccountId order by BaseSchedule__r.scheduleType__c, Name'));
  }

  
  public CustomSchedule__c findById(Id customScheduleId) {
    String columnsWithRelations = columns+innerSelectBuilder('RateOverrides__r', RateOverride.columns, 'order by CreatedDate desc')+',Account__r.id,Account__r.name,Account__r.accountNumber,BaseSchedule__r.name,BaseSchedule__r.scheduleType__c';    
    return (CustomSchedule__c)  Database.query(selectBuilder(table,columnsWithRelations,'where id =: customScheduleId'));
  }

  /**
   * Helper for Save
   */
  public CustomSchedule__c saveCustomSchedule(String name, Id accountId, Id baseScheduleId, String description, Boolean isDefault) { 
    CustomSchedule__c customSchedule = (CustomSchedule__c) new CustomSchedule.builderValidator()
      .forObject(new CustomSchedule__c())
      .set('name', name)
      .set('account__c', accountId)
      .set('baseSchedule__c', baseScheduleId)
      .set('description__c', description)
      .set('isDefault__c', isDefault)
      .buildAndValidate()
      .save();    
    return customSchedule;
  } 
}