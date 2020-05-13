@isTest
public with sharing class testAbstractSObject {

  static testMethod void testBadSaveWithDMLErrors() {
    //Try to save a schedule without the required description__c field
    try {
      new Schedule.builderValidator()
      .forObject(new Schedule__c())
      .set('name', 'fooSchedule')
      .save();
    }
    catch (ValidationException ve) {
      System.assert(ve!=null);
    }
  }  
    
  static testMethod void testBadSave() {
    //Try to save a bad plan 
    try {
      new Plan.builderValidator()
      .forObject(null)
      .save();      
    }
    catch (ValidationException ve) {
      System.assert(ve!=null);
    }    
  }
  
  static testMethod void testGetObject() {
    SObject so = new Pkg.builderValidator()
    .forObject(new Package__c())
    .getObject();
    
    System.assert(so != null);
  }
}