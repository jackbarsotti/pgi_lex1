@isTest(SeeAllData=true)
public with sharing class testAbstractRepository {

  public static Pkg pkg = new Pkg();

  //AbstractRepository.selectBuilder
  public static testMethod void testSelectBuilder() {
    //Assert that the correct select method is built as expected
    System.assert(pkg.selectBuilder('Table__c', 'id,name,foo', 'order by Id')
      .equals('select id,name,foo from Table__c order by Id'));
  }

  //AbstractRepository.innerSelectBuilder
  public static testMethod void testInnerSelectBuilder() {
    //Assert that the correct inner-select statement is built as expected
    System.assert(pkg.innerSelectBuilder('Foo__r', 'id,name,foo', 'order by bar')
      .equals(',(select id,name,foo from Foo__r order by bar)'));
  }

  //AbstractRepository.relationBuilder
  public static testMethod void testRelationBuilder() {
    //Assert that the correct relation is build as expected
    System.assert(pkg.relationBuilder('foo__r', 'id,name,foo')
      .equals(',foo__r.id,foo__r.name,foo__r.foo'));
  }
  public static testMethod void testfindMaxObjectId() {
    //Assert that the correct relation is build as expected
    System.debug('test---------------------------->'+pkg.findMaxObjectId('Schedule__c'));
  }
}