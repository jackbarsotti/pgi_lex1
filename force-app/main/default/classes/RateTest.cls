@isTest
public class RateTest {
    @testSetup static void setup() {
        Schedule__c schuduleObj = new Schedule__c();
        schuduleObj.Name = 'Tests1';
        schuduleObj.description__c='Test';
        schuduleObj.objectId__c=1;
        schuduleObj.scheduleType__c='Audio';
        Insert schuduleObj;
        ChargeCodeType__c chargeCodeTypeObj = new ChargeCodeType__c();
        chargeCodeTypeObj.Name='TestC1';
        chargeCodeTypeObj.description__c='ForTest';
        chargeCodeTypeObj.shortDescription__c='TestforTest';
        chargeCodeTypeObj.objectId__c=1;
        Insert chargeCodeTypeObj;
        ChargeCode__c chargeCodeObj =new ChargeCode__c();
        chargeCodeObj.Name='Testcc1';
        chargeCodeObj.description__c ='ForTest';
        chargeCodeObj.chargeCodeType__c =chargeCodeTypeObj.Id;
        Insert chargeCodeObj;
        List<ReadyTalk_Rate__c> readyTalkRateObj = new List<ReadyTalk_Rate__c>{new ReadyTalk_Rate__c(Name='Test1',	schedule__c=schuduleObj.Id,ReadyTalk_Rate__c=10,startDate__c=Date.today(),endDate__c=Date.today().addDays(2),objectId__c = 1,ChargeCode__c=chargeCodeObj.Id),
            new ReadyTalk_Rate__c(Name='Test2',	ReadyTalk_Rate__c=10,startDate__c=Date.today(),endDate__c=null,objectId__c = 2,schedule__c=schuduleObj.Id,ChargeCode__c=chargeCodeObj.Id)};
                Insert readyTalkRateObj;
    }
    static  testmethod void testRate(){
        Schedule__c scheduleObj =[Select Id,Name from Schedule__c Where Name ='Tests1'];
        ChargeCode__c chargeCodeObj = [Select Id,Name,description__c from ChargeCode__c Where Name ='Testcc1'];
        ReadyTalk_Rate__c readyTalkObj = [Select Id,name,chargeCode__c,endDate__c,ReadyTalk_Rate__c,schedule__c,startDate__c,objectId__c From ReadyTalk_Rate__c Where Name='Test1']; 
        Rate obj = new Rate();
        ReadyTalk_Rate__c readyTalkObjReturn =obj.findById(readyTalkObj.Id);
        System.assertEquals(readyTalkObj.chargeCode__c, readyTalkObjReturn.chargeCode__c);
        System.assertEquals(readyTalkObj.ReadyTalk_Rate__c, readyTalkObjReturn.ReadyTalk_Rate__c);
        List<ReadyTalk_Rate__c> readyTalkObjReturn1 =obj.findByScheduleIdAndChargeCodeId(scheduleObj.Id,chargeCodeObj.Id);
        System.assertEquals(readyTalkObj.chargeCode__c, readyTalkObjReturn1[0].chargeCode__c);
        System.assertEquals(readyTalkObj.ReadyTalk_Rate__c, readyTalkObjReturn1[0].ReadyTalk_Rate__c);
        ReadyTalk_Rate__c readyTalkObjReturn2=obj.saveRate('TestNew',chargeCodeObj.Id,'12/27/2015',11,scheduleObj.Id,'12/28/2015',3);
        System.assertEquals('TestNew', readyTalkObjReturn2.Name);
        System.assertEquals(Date.parse('12/28/2015'), readyTalkObjReturn2.endDate__c);
    }
    static  testmethod void testRateExpirePrevDate(){
       Schedule__c scheduleObj =[Select Id,Name from Schedule__c Where Name ='Tests1'];
        ChargeCode__c chargeCodeObj = [Select Id,Name,description__c from ChargeCode__c Where Name ='Testcc1'];
        ReadyTalk_Rate__c readyTalkObj = [Select Id,name,chargeCode__c,endDate__c,ReadyTalk_Rate__c,schedule__c,startDate__c,objectId__c From ReadyTalk_Rate__c Where Name='Test2'];
    	Rate obj = new Rate();
        obj.expirePreviousRate(chargeCodeObj.Id,scheduleObj.Id,'12/29/2015');
        ReadyTalk_Rate__c readyTalkObj1 = [Select Id,name,chargeCode__c,endDate__c,ReadyTalk_Rate__c,schedule__c,startDate__c,objectId__c From ReadyTalk_Rate__c Where Name='Test2'];
    	System.debug('The Ready Case'+readyTalkObj1);
        System.assertEquals(Date.parse('12/29/2015'), readyTalkObj1.endDate__c);
        System.assertEquals(scheduleObj.Id, readyTalkObj1.schedule__c);
        System.assertEquals(chargeCodeObj.Id, readyTalkObj1.chargeCode__c);
    }
}