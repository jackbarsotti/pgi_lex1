public with sharing abstract class AbstractSObject {
  
  public SObject o;

  public SObject save() {
    try {
      upsert(o);
    }
    catch(DmlException ex) {
      String error = '';      
      for(Integer x=0; x<ex.getNumDml(); x++) {
        if(ex.getDmlFields(x) != null) {
          for(SObjectField sof : ex.getDmlFields(x)) {
            error += sof.getDescribe().getLabel()+': '+ex.getDmlMessage(x);
          }
        }
        else
          error += ex.getDmlMessage(x);
      }
      throw new ValidationException(error);
    }
    catch(Exception e) {
      throw new ValidationException('Error while saving: '+e.getMessage());
    }
    return o;
  }
  
  public SObject getObject() {
    return this.o;
  }
}