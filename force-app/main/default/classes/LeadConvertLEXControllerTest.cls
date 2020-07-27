@isTest
public class LeadConvertLEXControllerTest {
static testmethod void testgetStatus(){
        Test.startTest();
        Lead leadObj=new Lead(LastName='test last',FirstName='test',Company='test Company',Status='Converted',Phone='74736475');
        INSERT leadObj;   
        LeadConvertLEXController.getStatus(leadObj.Id);           
        System.assertEquals('Converted', leadObj.Status);
        Test.stopTest();
    }
}