public with sharing class Pkg extends AbstractRepository {

  public final static String table = 'Package__c';
  public final static String columns = 'id,name,billableType__c,description__c,provisioningEmailDescription__c,provisioningEmailContext__c,QuantityEnabled__c';

  /**
   * Validations
   */  
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      Package__c pkg = (Package__c)o;
      
    }        
  }
  
  /**
   * Queries
   */
  public List<Package__c> findAllPackages(){
    String columnsWithRelations = columns+innerSelectBuilder('RT_Products__r', Product.columns, 'order by name');
    return (List<Package__c>) Database.query(selectBuilder(table,columnsWithRelations,'order by name'));
  }
  
  public Package__c findById(Id packageId) {
    String columnsWithRelations = columns+innerSelectBuilder('RT_Products__r', Product.columns, 'order by name'); 
    return (Package__c) Database.query(selectBuilder(table,columnsWithRelations,'where id =: packageId limit 1'));
  }

  public Package__c findByName(String name) {
    String columnsWithRelations = columns+innerSelectBuilder('RT_Products__r', Product.columns, 'order by name'); 
    return (Package__c) Database.query(selectBuilder(table,columnsWithRelations,'where name =: name limit 1'));    
  }

  /**
   * Helper for Save
   */
  public Package__c savePackage(String name, String billableType, String description, String emailContext) {
    Package__c p =  (Package__c) new Pkg.builderValidator()
      .forObject(new Package__c())
      .set('name', name)
      .set('billableType__c', billableType)
      .set('description__c', description)
      .set('provisioningEmailContext__c', emailContext)
      .buildAndValidate()
      .save();
    return p;
  }
}