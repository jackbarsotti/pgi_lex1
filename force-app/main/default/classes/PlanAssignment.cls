public with sharing class PlanAssignment extends AbstractRepository{

  public final static String table = 'PlanAssignment__c';
  public final static String columns = 'id,name,plan__c,sObjectApiName__c,startDate__c,endDate__c,sObjectId__c,accessCode__c,FoxDen_User__c';  

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      PlanAssignment__c planAssignment = (PlanAssignment__c)o;
      
      this.notBlank(planAssignment.name, PlanAssignment__c.name.getDescribe().getLabel());
      this.startNotAfterEnd(planAssignment.startDate__c, planAssignment.endDate__c, 'Plan assignment');
      this.datesCannotOverlap(planAssignment);
      this.startNotBeforePlanStart(planAssignment);
    }

    public void datesCannotOverlap(PlanAssignment__c pa){
      PlanAssignment planAssignmentLookup = new PlanAssignment();
      String sObjectId = pa.sObjectId__c;
      List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(planAssignmentLookup.selectBuilder(PlanAssignment.table,PlanAssignment.columns,'where sObjectId__c = :sObjectId'));
      this.datesCannotOverlap(pa, planAssignments);     
    }

    public void datesCannotOverlap(PlanAssignment__c pa, List<PlanAssignment__c> planAssignments){
      for(PlanAssignment__c planAssignment : planAssignments){
        if(planAssignment.sObjectId__c.equals(pa.sObjectId__c))
          continue;

        if(RTUtils.dateInRange(pa.startDate__c, planAssignment.startDate__c, planAssignment.endDate__c, true, false)){
          throw new ValidationException('Start date ('+pa.startDate__c+') falls between existing plan assignment start/end dates.<br/> - '+planAssignment.name+' start: '+planAssignment.startDate__c+' end: '+planAssignment.endDate__c);
        }

        if(RTUtils.dateInRange(pa.endDate__c, planAssignment.startDate__c, planAssignment.endDate__c, false, true)){
          throw new ValidationException('End date falls between existing plan assignment start/end dates.<br/> - '+planAssignment.name+' start: '+planAssignment.startDate__c+' end: '+planAssignment.endDate__c);
        }
      }
    }

    public void startNotBeforePlanStart(PlanAssignment__c pa){
      Plan planRepository = new Plan();
      Plan__c plan = planRepository.getById(pa.plan__c);

      if(RTUtils.dateIsBefore(pa.startDate__c, plan.startDate__c))
        throw new ValidationException('Plan start date cannot begin before account level plan start date.');
    }        
  }
  
  /**
   * Queries
   */
  public List<PlanAssignment__c> getByPlanId(Id planId){
    String columnWithRelations = columns+relationBuilder('plan__r', Plan.columns);
    List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where plan__c =: planId'));
    return planAssignments;
  }

  public List<PlanAssignment__c> getWhereSObjectIdInSet(Set<Id> idSet){
    String columnWithRelations = columns+relationBuilder('plan__r', Plan.columns);
    List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c in :idSet order by endDate__c desc'));
    return planAssignments;     
  }

  public List<PlanAssignment__c> getBySObjectId(String id){
    String columnWithRelations = columns+relationBuilder('plan__r', Plan.columns);    
    List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c =: id order by endDate__c desc'));
    return planAssignments;    
  }

  public PlanAssignment__c getCurrentPlanAssignmentBySObjectId(String id){
    String columnWithRelations = columns+relationBuilder('plan__r', Plan.columns);
    Date d = Date.today();

    List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c =: id and startDate__c <= :d and (endDate__c = null or endDate__c >= :d)'));    
    if(planAssignments.size() > 0)
      return planAssignments.get(0);
    else{
      planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c =: id order by endDate__c desc limit 1'));    
      if(planAssignments.size() > 0)
        return planAssignments.get(0);
      else
        return null;
    }
  }

  public PlanAssignment__c getLatestPlanAssignmentBySObjectId(String id){
    String columnWithRelations = columns+relationBuilder('plan__r', Plan.columns);
    
    List<PlanAssignment__c> planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c =: id and endDate__c = null'));    
    if(planAssignments.size() > 0)
      return planAssignments.get(0);
    else{
      planAssignments = (List<PlanAssignment__c>) Database.query(selectBuilder(table,columnWithRelations,'where sObjectId__c =: id order by endDate__c desc limit 1'));    
      if(planAssignments.size() > 0)
        return planAssignments.get(0);
      else
        return null;
    }
  }

  /**
  * Helper for save
  */
  public PlanAssignment__c savePlanAssignment(String name, Id planId, String sObjectApiName, Id sObjectId, Date startDate, Date endDate) {
    String fieldValue = sObjectApiName == 'Subscription__c' ? 'accessCode__c' : sObjectApiName;
    
    //Retrieve the contact__c link for this plan assignment.    
    SObject obj = Database.query('select Id, contact__c from '+sObjectApiName+' where Id = :sObjectId');
    Id contactId = (Id) obj.get('contact__c');

    PlanAssignment__c planAssignment = (PlanAssignment__c) new PlanAssignment.builderValidator()
      .forObject(new PlanAssignment__c())
      .set('name', name)
      .set('plan__c', planId)
      .set('contact__c', contactId)
      .set('sObjectApiName__c', sObjectApiName)
      .set('sObjectId__c', sObjectId)
      .set(fieldValue,sObjectId)
      .set('startDate__c', startDate)
      .set('endDate__c', endDate)
      .buildAndValidate()
      .save();    
    return planAssignment;
  }

  public PlanAssignment__c savePlanAssignment(String name, Id planId, String sObjectApiName, Id sObjectId, String startDate, String endDate) { 
    return savePlanAssignment(name, planId, sObjectApiName, sObjectId, Date.parse(startDate), endDate==null||endDate=='null' ? null : Date.parse(endDate));
  } 
}