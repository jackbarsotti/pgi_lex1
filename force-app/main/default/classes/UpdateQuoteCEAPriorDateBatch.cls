/*********************************************************************
Name : UpdateQuoteCEAPriorDateBatch
Created On : Mar 2, 2016
Created By : Archana Rajendran
Description : Batch Apex to update CEA Date Prior-to-Renewal and CEA Active Date 
**********************************************************************/
global class UpdateQuoteCEAPriorDateBatch implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        /*
String query = 'Select id,File_Store_Contract_Status__c,SC_Auto_renewal_Interval_in_months__c,CEA_Date_Prior_to_Renewal__c,CEA_Date_Active__c from quote where '+
'CEA_Date_Active__c < TODAY '+
'and SC_Auto_renewal_Interval_in_months__c != NULL '+
'and File_Store_Contract_Status__c = \'Active\''; */
        String query = 'Select id,Contract_Document_Status__c,Auto_Renewal_Interval_months__c,CEA_Date_Prior_to_Renewal__c,CEA_Date_Active__c from CONMAN_Contract__c where '+
            'CEA_Date_Active__c < TODAY '+
            'and Auto_Renewal_Interval_months__c != NULL '+
            'and Contract_Document_Status__c = \'Active\'';               
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<CONMAN_Contract__c> scope)
    {   
        for(CONMAN_Contract__c q:scope)
        {
            /* ORIGINAL
            q.CEA_Date_Prior_to_Renewal__c = q.CEA_Date_Active__c;
            date newdate = q.CEA_Date_Active__c;
            do {
            newdate = q.CEA_Date_Active__c.addmonths(integer.valueof(q.Auto_Renewal_Interval_months__c));
            q.CEA_Date_Active__c = newdate;
            } while (newdate <= system.today()); */
            
            // Only renew if the Active Date is in the past
            if (q.CEA_Date_Active__c <= System.today()) {
                q.CEA_Date_Prior_to_Renewal__c = q.CEA_Date_Active__c;
                
                // Skip those without renewal intervals
                if (q.Auto_Renewal_Interval_months__c == null || q.Auto_Renewal_Interval_months__c <= 0)
                    continue;
                
                Integer monthsOld = q.CEA_Date_Active__c.monthsBetween(System.today());
                Integer monthsRenew = Integer.valueof(q.Auto_Renewal_Interval_months__c);
                
                Integer renewalTimes;
                if (monthsOld <= 0) {
                    // If we're within a month of the Active Date,
                    // monthsOld will be 0 but we can trust that
                    // it's expired considering the <= today check
                    renewalTimes = 1;
                } else {
                    // Renew based on passed term lengths
                    renewalTimes = monthsOld / monthsRenew;
                    // If there's months left over (division remainder),
                    // add another term
                    if (Math.mod(monthsOld, monthsRenew) != 0)
                        renewalTimes += 1;
                }
                
                q.CEA_Date_Active__c = q.CEA_Date_Active__c.addMonths(renewalTimes * monthsRenew);
                
                // One last check to catch instances when the
                // difference is one whole term plus a few days old
                // e.g. 12m term on a 12m 15d old agreement
                // and monthsOld will only be 12
                if (q.CEA_Date_Active__c <= System.today())
                	q.CEA_Date_Active__c = q.CEA_Date_Active__c.addMonths(monthsRenew);
            }
        }
        update scope;
    }    
    global void finish(Database.BatchableContext BC)    
    {
        
    }
}