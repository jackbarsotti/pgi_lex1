public with sharing class FoxDenUser extends AbstractRepository {

  public final static String table = 'FoxDen_User__c';
  public final static String columns = 'id,Account__c,Auth0_User_Id__c,Contact__c,Date_Deleted__c,Inactive__c,Deleted_By__c,Email__c,Password__c,ProvisioningEmailSent__c,Status__c,Status_Description__c,Subscriber_Account__c';

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {      
    public override void validate(SObject o) { 
      FoxDen_User__c user = (FoxDen_User__c)o; 
    }
  }
  
  /**
   * Queries
   */  
  public FoxDen_User__c findById(Id userId) {    
    return (FoxDen_User__c) Database.query(selectBuilder(table,columns,'where id = :userId limit 1'));
  }
}