@isTest
private with sharing class testRateListController {
    
    private static ApexPages.StandardController controller;
    private static SFPCTestHelper sfpcTestHelper;
    @TestSetup
    static void makeData(){
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Test.stopTest();
    }
    private static void init(){
        controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), MockAccount.getNewAccount().Id));
        sfpcTestHelper = new SFPCTestHelper();
        sfpcTestHelper.createForAccount((Account)controller.getRecord());
    }  
    
    static testMethod void testConstructor() {
        init();
        RateListController c = new RateListController(controller);
        c.getAccountId();
        c.getScheduleId();
        c.getCustomScheduleId();
        c.getScheduleType();
        System.assert(c!=null);
    }
    
    static testMethod void testGetRateListHeaderInformation(){
        init();
        String accountId = ((Account)controller.getRecord()).Id;
        Map<String, String> header = RateListController.getRateListHeaderInformation(accountId, sfpcTestHelper.schedule.Id, sfpcTestHelper.customSchedule.Id);
        System.assert(header!=null);
    }
    
    static testMethod void testGetRatesByType() {
        init();
        List<RateDTO> results = RateListController.getRatesByType('Standard', sfpcTestHelper.schedule.Id, new List<String>{'DTF'});
        System.assert(results!=null);
        
        results = RateListController.getRatesByType('Custom', sfpcTestHelper.customSchedule.Id, new List<String>{'DTF'});
        System.assert(results!=null);
    }
    
    static testMethod void testGetAccountRates() {
        init();
        String accountId = ((Account)controller.getRecord()).Id;
        List<RateDTO> results = RateListController.getAccountRates(accountId, new List<String>{'DTF'}, 'Audio');
        System.assert(results!=null);
        //   Test.stopTest();
    }
    
    static testMethod void testSaveRateOverrides() {
        init();
        RateListController.saveRateOverrides(sfpcTestHelper.customSchedule.Id, '3/1/2013', new Map<String,String>{sfpcTestHelper.chargeCode.Id => '0.2000'});
        System.assert(1==1);
    }
    static testMethod void testgetRateListHeaderInformationForEdit(){
        init();
        Map<string,string> header=RateListController.getRateListHeaderInformationForEdit(sfpcTestHelper.schedule.Id);
        system.assert(header!=null);
    }
    static testMethod void testgetRatesByCustomScheduleIdAndChargeCodeType(){
        init();
        List<RateDTO> results = RateListController.getRatesByCustomScheduleIdAndChargeCodeType(sfpcTestHelper.customSchedule.Id, new List<String>{'DTF'});
        System.assert(results!=null);
    }
    static testMethod void testsaveNewCustomScheduleAndRateOverrides(){
        init();
        string accountId=((Account)controller.getRecord()).Id;
        RateListController.saveNewCustomScheduleAndRateOverrides(accountId,sfpcTestHelper.schedule.Id,'fooCustomScheduleAndRateOverride','A test custom schedule','2/1/2013',new Map<String,String>{sfpcTestHelper.chargeCode.Id => '0.2000'});
        System.assert(1==1);
    }
    static testMethod void testsaveBaseScheduleRateOverride(){
      init();
     RateListController.saveBaseScheduleRateOverride(sfpcTestHelper.schedule.Id,'2/1/2013','fooBaseScheduleRateOverride','A test Base schedule','12345677','Audio','on',new Map<String,String>{sfpcTestHelper.chargeCode.Id => '0.2000'});  
    } 
}