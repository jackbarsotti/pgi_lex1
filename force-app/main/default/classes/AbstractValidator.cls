public with sharing abstract class AbstractValidator extends AbstractSObject {
  
  public void notBlank(String s, String label) {
    if(s==null || s.trim().length() == 0 )
      throw new ValidationException(label+': cannot be blank');
  }

  public void startNotAfterEnd(Date startDate, Date endDate, String label){
    if(startDate==null)
      throw new ValidationException('Start date cannot be blank');

    if(endDate==null)
      return;

    if(startDate.daysBetween(endDate)<0)
      throw new ValidationException('End date cannot be before start date on '+label+' with start: '+startDate.format()+' and end: '+endDate.format());
  }

  public AbstractValidator forObject(SObject o) {
    this.o = o;
    return this;
  }
  
  public AbstractValidator set(String fieldName, Object value) {
    this.o.put(fieldName, value);
    return this;
  }
    
  public AbstractValidator buildAndValidate() {
    validate(this.o);      
    return this;
  }  
    
  public virtual void validate(SObject so) {}
}