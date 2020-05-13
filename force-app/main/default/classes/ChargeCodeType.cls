public with sharing class ChargeCodeType extends AbstractRepository {

  public final static String table = 'ChargeCodeType__c';
  public final static String columns = 'id,name,description__c,shortDescription__c';   
  
  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      ChargeCodeType__c c = (ChargeCodeType__c)o;
      
    }        
  } 
  
  /**
   * Queries
   */

  /**
  * Helper for Save
  */
  public ChargeCodeType__c saveChargeCodeType(String name, String description, String shortDescription) { 
    ChargeCodeType__c c = (ChargeCodeType__c) new ChargeCodeType.builderValidator()
      .forObject(new ChargeCodeType__c())
      .set('name', name)
      .set('description__c', description)
      .set('shortDescription__c', shortDescription)
      .buildAndValidate()
      .save();    
    return c;
  }   
}