/**
* Used to roll up the total single charge, recurring charge, and frequency for a plan
*/
public with sharing class OverridesTotalDTO {
  public Decimal recurringCharge {get; set;}
  public Decimal singleCharge {get; set;}
  public String frequency {get; set;}
  
  public void addRecurringCharge(SObject overrideObject) {
  	Decimal newRecCharge = (Decimal)overrideObject.get('recurringCharge__c');
  	if (recurringCharge == null) {
  		recurringCharge = newRecCharge;
  	} else {
      if (newRecCharge != null) {
      	recurringCharge += newRecCharge;
      }
  	}
    /*
  	String freq = (String)overrideObject.get('recurringChargeFrequency__c');
  	if (frequency == null) {
  		frequency = freq;
  	} else {
      //NO!  This may be the frequency from a base product, chage this
  		if (frequency != freq) {
  			frequency = frequency + ', '+ freq;
  		}
  	}
    */
  }
  
  public void addSingleCharge(SObject overrideObject) {
  	Decimal newSingleCharge = (Decimal)overrideObject.get('singleCharge__c');
  	if (singleCharge == null) {
      singleCharge = newSingleCharge;
    } else {
      if (newSingleCharge != null) {
        singleCharge += newSingleCharge;
      }
    }
  }
}