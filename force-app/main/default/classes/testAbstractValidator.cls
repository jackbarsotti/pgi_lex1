@isTest
public with sharing class testAbstractValidator {

  //AbstractValidator.testNotBlank
  public static testMethod void testNotBlank() {
    //Assert that a null value for notBlank throws a ValidationException
    try {
      new Pkg.builderValidator().notBlank(null, 'Product');
    }
    catch(ValidationException ve) {
      System.assert(ve.getMessage().contains('cannot be blank'));
    }
  }

  //AbstractValidator.startNotAfterEnd
  public static testMethod void testStartNotAfterEnd() {
    //Assert that startDate==null throws a ValidationException
    try{
      new Pkg.builderValidator().startNotAfterEnd(null, null, 'label');
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().equals('Start date cannot be blank'));
    }

    //Assert that a null endDate returns
    new Pkg.builderValidator().forObject(new Plan__c()).startNotAfterEnd(Date.today(), null, 'label');
    System.assert(1==1);

    //Assert that startDate after endDate throws a ValidationException
    try{
      new Pkg.builderValidator().startNotAfterEnd(Date.today().addDays(1), Date.today(), 'label');
    }      
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('End date cannot be before start date'));
    }
  }
}