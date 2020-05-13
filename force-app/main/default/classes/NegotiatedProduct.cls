public with sharing class NegotiatedProduct extends AbstractRepository {

  public final static String table = 'NegotiatedProduct__c';
  public final static String columns = 'id,name,account__c,plan__c,product__c';
  
  /**
   * Validations
   */
  public class builderValidator extends AbstractValidator {  
    
    public override void validate(SObject o) {  
      NegotiatedProduct__c np = (NegotiatedProduct__c)o;

      this.notBlank(np.name, NegotiatedProduct__c.name.getDescribe().getLabel());
    }        
  } 
  
  /**
   * Queries
   */  
  public NegotiatedProduct__c getById(Id npId) {
    String columnsWithRelations = columns+relationBuilder('product__r', Product.columns)+relationBuilder('plan__r', Plan.columns)+',product__r.schedule__r.Name, product__r.schedule__r.scheduleType__c, account__r.id, account__r.parentID';
    return (NegotiatedProduct__c) Database.query(selectBuilder(table,columnsWithRelations,'where id = :npId limit 1'));
  }

  public List<NegotiatedProduct__c> getByPlanId(Id planId){
    List<NegotiatedProduct__c> negotiatedProducts = (List<NegotiatedProduct__c>) Database.query(selectBuilder(table,columns,'where plan__c =: planId'));
    return negotiatedProducts;
  }
  
  /**
   * Helper for save
   */
  public NegotiatedProduct__c saveNegotiatedProduct(String name, Id productId, Id planId, Id accountId) {
    NegotiatedProduct__c np = (NegotiatedProduct__c) new NegotiatedProduct.builderValidator()
      .forObject(new NegotiatedProduct__c())
      .set('name', name)
      .set('product__c', productId)
      .set('plan__c', planId)
      .set('account__c', accountId)
      .buildAndValidate()
      .save();
    return np;
  }    
}