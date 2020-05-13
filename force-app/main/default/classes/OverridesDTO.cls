public with sharing class OverridesDTO {
  public SObject singleChargeOverride {get; set;}
  public SObject recurringChargeOverride {get; set;}
  public SObject scheduleOverride {get; set;}
  public Boolean hasScheduleOverride {get; set;}
  public Boolean hasCustomSchedule {get; set;}
  public String viewScheduleURLParams {get; set;}
}