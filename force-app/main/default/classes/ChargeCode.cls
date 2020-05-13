public with sharing class ChargeCode extends AbstractRepository {

  public final static String table = 'ChargeCode__c';
  public final static String columns = 'id,name,chargeCodeType__c,countryAbbreviation__c,description__c';   
  
  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      ChargeCode__c c = (ChargeCode__c)o;
      
    }        
  } 
  
  /**
   * Queries
   */

  /**
  * Helper for Save
  */
  public ChargeCode__c saveChargeCode(String name, Id chargeCodeTypeId, String countryAbbreviation, String description) { 
    ChargeCode__c c = (ChargeCode__c) new ChargeCode.builderValidator()
      .forObject(new ChargeCode__c())
      .set('name', name)
      .set('chargeCodeType__c', chargeCodeTypeId)
      .set('countryAbbreviation__c', countryAbbreviation)
      .set('description__c', description)
      .buildAndValidate()
      .save();    
    return c;
  }   
}