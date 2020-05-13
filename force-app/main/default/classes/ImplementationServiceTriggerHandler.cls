public without sharing class ImplementationServiceTriggerHandler extends TriggerHandler {
    public ImplementationServiceTriggerHandler() {
        super('ImplementationServiceTriggerHandler');
    }
	protected override void beforeInsert() {
		setCancelledCompletedDate();
		caputureNurtureDates();
        setPhaseDates();
	}
	protected override void beforeUpdate() {
		setCancelledCompletedDate();
		caputureNurtureDates();
        setPhaseDates();
	}
	private void setCancelledCompletedDate() {
		for(Implementation_Services__c ist : (List<Implementation_Services__c>)Trigger.new) {
			if(isChanged('IST_Completed_Status__c', ist) && (ist.IST_Completed_Status__c == 'Cancelled' || ist.IST_Completed_Status__c == 'Completed')) {
				ist.Completed_Date__c = System.today();
			}
		}
	}
	private void caputureNurtureDates() {
		for(Implementation_Services__c ist : (List<Implementation_Services__c>)Trigger.new) {
			if(isChanged('IST_Completed_Status__c', ist) && (ist.IST_Completed_Status__c == 'Nurture')) {
				ist.Start_Nurture__c = System.today();
			}
		}
		if(Trigger.old != null) {
			for(Implementation_Services__c ist : (List<Implementation_Services__c>)Trigger.new) {
				Implementation_Services__c oldIST = (Implementation_Services__c)Trigger.oldMap.get(ist.Id);
				if(isChanged('IST_Completed_Status__c', ist) && (ist.IST_Completed_Status__c != 'Nurture') && (oldIST.IST_Completed_Status__c == 'Nurture')) {
					ist.End_Nurture__c = System.today();
				}
			}
		}
	}
    private void setPhaseDates() {
		for(Implementation_Services__c ist : (List<Implementation_Services__c>)Trigger.new) {
            Implementation_Services__c oldIST = new Implementation_Services__c();
            if(Trigger.old != null) {
                oldIST = (Implementation_Services__c)Trigger.oldMap.get(ist.Id);
            }
            /* Ensure all process/phase count downs STOP if Status is every moved out of Open to any other Status value. */
            if(ist.IST_Completed_Status__c != 'Open') {
                if(ist.Phase_1_Pause_Date__c == null) {
                    ist.Phase_1_Pause_Date__c = System.today();
                }
                if(ist.Phase_2_Pause_Date__c == null) {
                    ist.Phase_2_Pause_Date__c = System.today();
                }
                if(ist.Phase_3_Pause_Date__c == null) {
                    ist.Phase_3_Pause_Date__c = System.today();
                }
            }
            if(ist.Phase_1_Start_Date__c == null) {
                if(ist.Implementation_Stage__c == 'Plan' && ist.IST_Completed_Status__c == 'Open') {
                    ist.Phase_1_Start_Date__c = System.today();
                    ist.Phase_1_End_Date__c = System.today() + 28;
                }
            }
            if(ist.Implementation_Stage__c != 'Plan' && ist.Implementation_Stage__c != 'On-Hold' && ist.Phase_1_Start_Date__c != null) {
				System.debug(ist.Phase_1_Pause_Date__c);
                if(ist.Phase_1_Pause_Date__c == null) {
                    ist.Phase_1_Pause_Date__c = System.today();
                }
            }
			System.debug(ist.Phase_2_Start_Date__c);
			System.debug(ist.Implementation_Stage__c); 
            System.debug(ist.IST_Completed_Status__c); 
            if(ist.Phase_2_Start_Date__c == null) {
                if(ist.Implementation_Stage__c == 'Build' && ist.IST_Completed_Status__c == 'Open') {
                    ist.Phase_2_Start_Date__c = System.today();
                    ist.Phase_2_End_Date__c = System.today() + 28;
                }
            }
            if(ist.Implementation_Stage__c != 'Build' && ist.Implementation_Stage__c != 'On-Hold' && ist.Phase_2_Start_Date__c != null) {
                if(ist.Phase_2_Pause_Date__c == null) {
                    ist.Phase_2_Pause_Date__c = System.today();
                }
            }
            
            if(ist.Phase_3_Start_Date__c == null) {
                if(ist.Implementation_Stage__c == 'Train' && ist.IST_Completed_Status__c == 'Open') {
                    ist.Phase_3_Start_Date__c = System.today();
                    ist.Phase_3_End_Date__c = System.today() + 35;
                }
            }
            if(ist.Implementation_Stage__c != 'Train' && ist.Implementation_Stage__c != 'On-Hold' && ist.Phase_3_Start_Date__c != null) {
                if(ist.Phase_3_Pause_Date__c == null) {
                    ist.Phase_3_Pause_Date__c = System.today();
                }
            }

            if(ist.Implementation_Stage__c == 'On Hold' && oldIST.Implementation_Stage__c != 'On Hold') {
                //held record
                ist.Date_of_Stage_Off_Hold__c = null;
                ist.Date_of_Stage_On_Hold__c = System.today();
                /*
                if(ist.Phase_1_Start_Date__c != null && ist.Phase_1_Pause_Date__c == null) {

                    //phase 1					
                } else if(ist.Phase_2_Start_Date__c != null && ist.Phase_2_Pause_Date__c == null) {
                  
					//phase 2					
                } else if(ist.Phase_3_Start_Date__c != null && ist.Phase_3_Pause_Date__c == null) {
                  
					//phase 3
                }
				*/
            } else if(ist.Implementation_Stage__c != 'On Hold' && oldIST.Implementation_Stage__c == 'On Hold') {
                if(ist.Total_of_Days_on_Hold__c == null) {
                    ist.Total_of_Days_on_Hold__c = 0;
                }
                ist.Date_of_Stage_Off_Hold__c = System.today();
                //unheld records
                if(ist.Phase_1_Start_Date__c != null && ist.Phase_1_Pause_Date__c == null) {
                    //phase 1
                    if(ist.Phase_1_Pause_Days__c == null) {
                        ist.Phase_1_Pause_Days__c = 0;
                    }
                    if(ist.Date_of_Stage_On_Hold__c != null) {
                        ist.Phase_1_Pause_Days__c += ist.Date_of_Stage_On_Hold__c.daysBetween(ist.Date_of_Stage_Off_Hold__c);
                    }
                } else if(ist.Phase_2_Start_Date__c != null && ist.Phase_2_Pause_Date__c == null) {
					//phase 2	
					if(ist.Phase_2_Pause_Days__c == null) {
                        ist.Phase_2_Pause_Days__c = 0;
                    }
                    if(ist.Date_of_Stage_On_Hold__c != null) {
                        ist.Phase_2_Pause_Days__c += ist.Date_of_Stage_On_Hold__c.daysBetween(ist.Date_of_Stage_Off_Hold__c);
                    }
                } else if(ist.Phase_3_Start_Date__c != null && ist.Phase_3_Pause_Date__c == null) {
					//phase 2	
					if(ist.Phase_3_Pause_Days__c == null) {
                        ist.Phase_3_Pause_Days__c = 0;
                    }
                    if(ist.Date_of_Stage_On_Hold__c != null) {
                        ist.Phase_3_Pause_Days__c += ist.Date_of_Stage_On_Hold__c.daysBetween(ist.Date_of_Stage_Off_Hold__c);
                    }
                }
                if(ist.Date_of_Stage_On_Hold__c != null) {
	                ist.Total_of_Days_on_Hold__c += ist.Date_of_Stage_On_Hold__c.daysBetween(ist.Date_of_Stage_Off_Hold__c);
                    ist.Date_of_Stage_On_Hold__c = null;
                }
            }
        }
    }
}