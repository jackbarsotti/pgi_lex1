public with sharing class Product extends AbstractRepository {

  public final static String table = 'RT_Product__c';
  public final static String columns = 'id,name,package__c,recurringCharge__c,recurringChargeFrequency__c,schedule__c,scheduleName__c,singleCharge__c,useAssignedScheduleAsDefault__c,type__c';

  /**
   * Validations
   */  
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      RT_Product__c product = (RT_Product__c)o;
      
    }        
  } 

  /**
   * Queries
   */

  /**
   * Helper for Save
   */
  public RT_Product__c saveProduct(String name, Id packageId, Decimal recurringCharge, String recurringChargeFrequency, Id scheduleId, Decimal singleCharge, String type, boolean isDefault) {
    RT_Product__c p = (RT_Product__c) new Product.builderValidator()
      .forObject(new RT_Product__c())
      .set('name', name)
      .set('package__c', packageId)
      .set('recurringCharge__c', recurringCharge)
      .set('recurringChargeFrequency__c', recurringChargeFrequency)
      .set('schedule__c', scheduleId)
      .set('singleCharge__c', singleCharge)
      .set('type__c', type)
      .set('useAssignedScheduleAsDefault__c', isDefault)
      .buildAndValidate()
      .save();
    return p;
  }        
}