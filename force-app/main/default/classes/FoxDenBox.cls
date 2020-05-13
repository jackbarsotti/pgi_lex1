public with sharing class FoxDenBox extends AbstractRepository {

  public final static String table = 'FoxDen_Box__c';
  public final static String columns = 'id,name,Account__c,Auth0_User_Id__c,Beacon_Id__c,Beacon_Major_Value__c,Beacon_Minor_Value__c,Inactive__c,Kiosk_Email__c,Password__c,sku__c,Status__c,Status_Description__c';

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {      
    public override void validate(SObject o) {  
      FoxDen_Box__c box = (FoxDen_Box__c)o;      
      this.accountHasFoxDenAccountLicense(box);      
    }

    public void accountHasFoxDenAccountLicense(FoxDen_Box__c box){
      if(box.Account__c == null)
        return;
      else{
        Plan planRepository = new Plan();
        List<Plan__c> plans = planRepository.getPlansByAccountIdAndName(box.Account__c, 'FoxDen Connect In-Room System');
        if(plans == null || plans.size() < 1)
          throw new ValidationException('A FoxDen - Connect In-Room System plan needs to be added to this account before assigning a FoxDen Box');
      }
    }
  }
  
  /**
   * Queries
   */  
  public FoxDen_Box__c findById(Id boxId) {    
    return (FoxDen_Box__c) Database.query(selectBuilder(table,columns,'where id = :boxId limit 1'));
  }

  public List<FoxDen_Box__c> getFoxDenBoxesInSet(List<Id> s){
    List<FoxDen_Box__c> boxes = (List<FoxDen_Box__c>) Database.query(selectBuilder(table,columns,'where id in : s'));
    return boxes;    
  }

  /*
  * Returns FoxDen boxes that are unassigned (NOTE: Limits to 30 ATM)
  */
  public List<FoxDen_Box__c> getFoxDenBoxesWhereAccountIdIsNullAndActive(){
    List<FoxDen_Box__c> boxes = (List<FoxDen_Box__c>) Database.query(selectBuilder(table,columns,'where account__c = null and Inactive__c = false and Status__c = \'Active\' order by CreatedDate asc limit 30'));
    return boxes;
  }

  public FoxDen_Box__c assignBox(Id accountId, FoxDen_Box__c foxDenBox) { 
    FoxDen_Box__c box = (FoxDen_Box__c) new FoxDenBox.builderValidator()
      .forObject(foxDenBox)
      .set('account__c', accountId)
      .buildAndValidate()
      .getObject();   
    return box;
  }  
}