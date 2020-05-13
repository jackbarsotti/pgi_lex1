public with sharing class SFPCTestHelper {

  public Package__c pkg;
  public Package__c quantityPkg;
  public Schedule__c schedule;
  public RT_Product__c product;
  public Plan__c plan;
  public Plan__c fdPlan;
  public Plan__c s3Plan;
  public Plan__c quantityPlan;
  public CustomSchedule__c customSchedule;
  public NegotiatedProduct__c negotiatedProduct;
  public SingleChargeOverride__c singleChargeOverride;
  public RecurringChargeOverride__c recurringChargeOverride;
  public ScheduleOverride__c scheduleOverride;
  public ChargeCode__c chargeCode;
  public ChargeCodeType__c chargeCodeType;
  public ReadyTalk_Rate__c rate;
  public RateOverride__c rateOverride;

  public Package__c unassignedPackage;
  public Plan__c unassignedPlan;
  public Schedule__c unassignedSchedule;

  public Package__c unassignedPackage2;
  public RT_Product__c unassignedProduct;

  public PlanAssignment__c accessCodePlanAssignment;
  public PlanAssignment__c foxDenPlanAssignment;
  public PlanAssignment__c s3UserPlanAssignment;

  public Subscription__c subscription;
  public FoxDen_User__c foxDenUser;
  public S3User__c s3User;

  public void createForAccount(Account account) {    
    
    Pkg packageRepo = new Pkg();
    Schedule scheduleRepo = new Schedule();
    Product productRepo = new Product();
    Plan planRepo = new Plan();
    CustomSchedule customScheduleRepo = new CustomSchedule();
    NegotiatedProduct npRepo = new NegotiatedProduct();
    SingleChargeOverride scoRepo = new SingleChargeOverride();
    RecurringChargeOverride rcoRepo = new RecurringChargeOverride();
    ScheduleOverride soRepo = new ScheduleOverride();
    RateOverride roRepo = new RateOverride();
    Rate rateRepo = new Rate();   
    ChargeCodeType chargeCodeTypeRepo = new ChargeCodeType();
    ChargeCode chargeCodeRepo = new ChargeCode(); 
    PlanAssignment planAssignmentRepo = new PlanAssignment();
    subscription = MockSubscription.getNewSubscription();
    foxDenUser = MockFoxDenUser.getNewFoxDenUser();
    s3User = MockS3User.getNewS3User();

    String emailContext = '{"package":{"name":"Meeting Free Trial"}, "card":{"callMeAnchorText": "callme.readytalk.com", "callMeAnchorType": "callme", "callMeText": "Audio & Online Meetings", "renderVOIPLinkData": true }, "startButton":{"renderStartMeetingButton": true, "startMeetingButtonText": "Start My First Meeting Now"} }';

   Test.startTest();

    pkg = packageRepo.savePackage('fooPackage', 'ACCESS_CODE', 'A test package', emailContext);
    quantityPkg = packageRepo.savePackage('quantityPackage', 'ACCESS_CODE', 'A test package', emailContext);
    quantityPkg.quantityEnabled__c = true;
    update quantityPkg;
    schedule = scheduleRepo.saveSchedule('fooSchedule', 'A test schedule', 'Audio', Math.Random() * 100);
    product = productRepo.saveProduct('fooProduct', pkg.Id, 49.00, 'INVOICE', schedule.Id, 0.00, 'WEB', true);
    plan = planRepo.savePlan('fooPlan', account.Id, pkg.Id, 'ACCESS_CODE', '1/1/2013', null, null, null);
    fdPlan = planRepo.savePlan('fdPlan', account.Id, pkg.Id, 'FOXDEN_USER', '1/1/2013', null, null, null);
    s3Plan = planRepo.savePlan('s3Plan', account.Id, pkg.Id, 'S3_USER', '1/1/2013', null, null, null);
    quantityPlan = planRepo.savePlan('quantityPlan', account.Id, quantityPkg.Id, 'SEAT', '1/1/2013', null, '10', '1/1/2017');
    customSchedule = customScheduleRepo.saveCustomSchedule('fooCustomSchedule', account.Id, schedule.Id, 'A test custom schedule', false);
    negotiatedProduct = npRepo.saveNegotiatedProduct('fooNP', product.Id, plan.Id, account.Id);
    singleChargeOverride = scoRepo.saveSingleChargeOverride('fooSCO', 0.00, negotiatedProduct.Id, 49.00, '1/1/2013', null);
    recurringChargeOverride = rcoRepo.saveRecurringChargeOverride('fooRCO', 0.00, negotiatedProduct.Id, 1.00, 'INVOICE', '1/1/2013', null);
    scheduleOverride = soRepo.saveScheduleOverride('fooSO', negotiatedProduct.Id, schedule.Id, customSchedule.Id, '2/1/2013', null);
    chargeCodeType = chargeCodeTypeRepo.saveChargeCodeType('DTF', 'Audio: Domestic Toll-Free Usage', 'Dom Toll-Free');
    chargeCode =  chargeCodeRepo.saveChargeCode('USA-TF', chargeCodeType.Id, 'USA', 'United States Toll Free');
    rate = rateRepo.saveRate('fooRate', chargeCode.Id, '1/1/2013', 0.1000, schedule.Id, null, Math.Random() * 9999999);
    rateOverride = roRepo.saveRateOverride(chargeCode.Id, customSchedule.Id, 'fooRateOverride', 0.2000, '2/1/2013', null);  

    unassignedPackage = packageRepo.savePackage('unassignedPackage', 'ACCESS_CODE', 'A test package', emailContext);
    unassignedPlan = planRepo.savePlan('unassignedPlan', account.Id, unassignedPackage.Id, 'ACCESS_CODE', '1/1/2013', null, null, null);
    unassignedSchedule = scheduleRepo.saveSchedule('unassignedSchedule', 'A test schedule #2', 'Audio', Math.Random() * 101);

    unassignedPackage2 = packageRepo.savePackage('unassignedPackage2', 'ACCESS_CODE', 'A test package #2', emailContext);
    unassignedProduct = productRepo.saveProduct('unassignedProduct', unassignedPackage2.Id, 49.00, 'INVOICE', schedule.Id, 0.00, 'WEB', true);    

    accessCodePlanAssignment = planAssignmentRepo.savePlanAssignment('acPlanAssignment', plan.Id, 'Subscription__c', subscription.Id, Date.today(), null);
    foxDenPlanAssignment = planAssignmentRepo.savePlanAssignment('fdPlanAssignment', fdPlan.Id, 'FoxDen_User__c', foxDenUser.Id, Date.today(), null);
  }
}