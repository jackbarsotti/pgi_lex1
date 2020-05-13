public with sharing class SubscriptionEmailTemplateHelper {

  public String subId {get; set;}
  public Subscription subscriptionRepo = new Subscription();
  public PlanAssignment planAssignmentRepo = new PlanAssignment();
  public Pkg packageRepo = new Pkg();
  public Map<String,Object> defaultContext = new Map<String,Object>{
    'package' => new Map<String,Object>{'name' => 'Define package.name', 'numberSeats' => 0, 'headerText' => ''},
    'card' => new Map<String,Object>{'callMeAnchorText' => 'Define card.callMeAnchorText', 'callMeAnchorType' => 'define card.callMeAnchorType', 'callMeText' => 'Define card.callmeText', 'renderTollFreeLinkData' => false, 'renderTollFreeNumberData' => false, 'renderVOIPLinkData' => false, 'renderBroadcastAudioLinkData' => false},    
    'startButton' => new Map<String,Object>{'renderStartMeetingButton' => false, 'startMeetingButtonText' => 'Define startButton.startMeetingButtonText', 'renderScheduleWebinarButton' => false, 'renderScheduleWebinarText' => 'Define startButton.renderScheduleWebinarText'},
    'details' => new Map<String,Object>{'renderGetStarted' => false, 'renderInvite' => false, 'renderLearn' => false, 'renderPlanning' => false, 
      'getStarted' => new Map<String,Object>{'renderGetStartedCallMe' => false, 'renderDesktopApp' => false, 'renderMobileApps' => false, 'renderCalendar' => false, 'renderScheduleWebinar' => false, 'renderStartWebinar' => false, 'renderIncludeBA' => false},
      'license' => new Map<String,Object>{'renderTFTollVoipAvailable' => false, 'renderChargeDetails' => false, 'intTFText' => 'Toll-Free & International Audio Packages available', 'videoHeaderText' => 'Unlimited Video Conferencing', 'licenseTypeText' => '', 'renderMeetingSectionText' => false, 'renderWebinarSectionText' => false, 'renderPhoneSection' => true, 'renderAudioPorts' => false, 'renderUnlimitedPhoneIn' => true, 'renderSSSBA' => false, 'renderUnlimitedDialOut' => false, 'renderUnlimitedVOIP' => false, 'renderIncludedMinutes' => false, 'includedMinutes' => 0, 'renderPhonePlusSection' => false, 'renderTollFreeNumber' => false, 'renderChargesApply' => false, 'renderInternationalNumbersLink' => false, 'renderINTTFAudioPackagesAvailable' => false, 'renderTFAudioPackagesAvailable' => false, 'renderUnlimitedRecording' => true, 'renderUnlimitedMeetings' => true, 'renderUnlimitedVideo' => true}
    }
  };

  public String getProvisioningEmailDescription() {
    PlanAssignment__c pa = planAssignmentRepo.getCurrentPlanAssignmentBySObjectId(this.subId);
    if(pa==null)
      return 'N/A';

    Package__c pkg = packageRepo.findById(pa.Plan__r.basePackage__c);
    return pkg.provisioningEmailDescription__c;
  }

  public Map<String,Object> getContext() {
    Map<String, Object> m = new Map<String,Object>();

    PlanAssignment__c pa = planAssignmentRepo.getCurrentPlanAssignmentBySObjectId(this.subId);
    if(pa==null)
      return m;

    Package__c pkg = packageRepo.findById(pa.Plan__r.basePackage__c);
    if(pkg==null || pkg.provisioningEmailContext__c == null)
      return m;

    m = (Map<String, Object>) JSON.deserializeUntyped(pkg.provisioningEmailContext__c);
    return mergeMaps(defaultContext, m);
  }

  public Subscription__c getSubscription() {
    Subscription__c subscription = subscriptionRepo.findById(this.subId);
    return subscription;
  }

  //Merge two maps, m1 being the master with defaults to be overwritten.  m2 should be a subset of m1
  public Map<String, Object> mergeMaps(Map<String, Object> m1, Map<String, Object> m2) { 
    Map<String, Object> mergedMap = new Map<String,Object>();
    
    for(String key : m1.keySet()){
      Object masterValue = m1.get(key);
      
      if(masterValue instanceof Map<String,Object>) {
        if(!m2.containsKey(key)){
          mergedMap.put(key, masterValue);
        }
        else{
          mergedMap.put(key, (mergeMaps((Map<String,Object>) masterValue, (Map<String,Object>) m2.get(key))));        
        }
      }
      else{
        if(!m2.containsKey(key)){
          mergedMap.put(key, masterValue);
        }
        else{
          mergedMap.put(key, m2.get(key));
        }
      }
    }
    return mergedMap;
  } 
}