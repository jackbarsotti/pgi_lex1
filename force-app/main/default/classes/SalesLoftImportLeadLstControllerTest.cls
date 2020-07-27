@isTest
public class SalesLoftImportLeadLstControllerTest {
    static testMethod void testGetRecords(){
        Lead leadObj=new Lead();
        leadObj.LeadSource='Contact Us';
        leadObj.Company='testCompany1';
        leadObj.LastName='testcontact22';
        leadObj.Phone='9787655444';
        INSERT leadObj;
        
        Lead leadObject=new Lead();
        leadObject.LeadSource='Contact Us';
        leadObject.Company='testCompany2';
        leadObject.LastName='testcon44';
        leadObject.Phone='9787655445';
        INSERT leadObject;
        
        List<Lead> leadList=new List<Lead>();
        leadList.add(leadObj);
        leadList.add(leadObject);
        Test.startTest();
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(leadList);
        stdSetController.setSelected(leadList);
		SalesLoftImportLeadLstController salesLoftControllerObj = new SalesLoftImportLeadLstController(stdSetController);
        PageReference custPage=salesLoftControllerObj.getRecords();
        System.assert(custPage!=null);
    }
}