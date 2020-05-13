global with sharing class RateDTO implements Comparable {
  public ReadyTalk_Rate__c currentRate {get;set;}
  public List<ReadyTalk_Rate__c> baseScheduleRates {get;set;}
  public List<RateOverride__c> rateOverrides {get;set;}

  global Integer compareTo(Object compareTo){
    RateDTO rateDTO = (RateDTO) compareTo;
    return currentRate.chargeCode__r.description__c.compareTo(rateDTO.currentRate.chargeCode__r.description__c);
  }
}