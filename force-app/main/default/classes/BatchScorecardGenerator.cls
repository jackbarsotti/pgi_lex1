/*
    Name: BatchScorecardGenerator; 
    Author:
    Description: This batch class is used for generating scorecard link and send to selected email address.
*/
global class BatchScorecardGenerator implements Database.Batchable<sObject>,Database.Stateful{
      
       
      global String urlEnds;
      global Date specifiedDate;
      private Integer insertedSize = 0;
      global BatchScorecardGenerator(Date specifiedDate){
            this.specifiedDate = specifiedDate;
            urlEnds = '';
      }
      global BatchScorecardGenerator(){
            urlEnds = '';
      }
      global BatchScorecardGenerator(String urlEnds){
             
            this.urlEnds = urlEnds;
      }
      global Database.QueryLocator start(Database.BatchableContext BC){ 
            //TODO - replace active with Show On Scorecard
            //IF Zero Closed Cases - Auto Generate score of 0 for all questions

            return Database.getQueryLocator([SELECT id FROM PGi_Vendor_List__c WHERE Show_on_Surveys__c = true]);
      }
      global void execute(Database.BatchableContext BC,List<PGi_Vendor_List__c> ListV){
            
            if(ListV != Null && ListV.size()>0){
            //Last month FROM today
            date tDate = Date.today().addMonths(-1);
            
            if(specifiedDate != null) 
                      tDate = specifiedDate;
                  else 
                      tDate = Date.today().addMonths(-1); 
            
            
            Integer monthNumber =  tDate.month();
            Integer yearNumber =  tDate.year();
            
            String monthSortName ='';
            if(monthNumber == 1){
                  monthSortName = 'Jan';
            }else if(monthNumber == 2){
                  monthSortName = 'Feb';
            }else if(monthNumber == 3){
                  monthSortName = 'Mar';
            }else if(monthNumber == 4){
                  monthSortName = 'Apr';
            }else if(monthNumber == 5){
                  monthSortName = 'May';
            }else if(monthNumber == 6){
                  monthSortName = 'Jun';
            }else if(monthNumber == 7){
                  monthSortName = 'Jul';
            }else if(monthNumber == 8){
                  monthSortName = 'Aug';
            }else if(monthNumber == 9){
                  monthSortName = 'Sep';
            }else if(monthNumber == 10){
                  monthSortName = 'Oct';
            }else if(monthNumber == 11){
                  monthSortName = 'Nov';
            }else if(monthNumber == 12){
                  monthSortName = 'Dec';
            }
            //For last month data : 
            
            urlEnds = monthSortName+'-'+String.ValueOf(yearNumber);
            
            set<Id> setVids = new set<Id>();
            
            for(PGi_Vendor_List__c vl : ListV){
                  setVids.add(vl.Id);
            }
            List<Vendor_Scorecard__c> lstVS = new List<Vendor_Scorecard__c>();
            if(setVids!= null && setVids.size()>0){
                  lstVS = [SELECT Id, Month_Year__c, Related_PGi_Vendor__c FROM Vendor_Scorecard__c WHERE Month_Year__c=: urlEnds and Related_PGi_Vendor__c IN: setVids];  
            }
            map<Id,Id> mapVenSc = new map<Id,Id>();
            if(lstVS!= null && lstVS.size()>0){
                  for(Vendor_Scorecard__c vs : lstVS){
                        mapVenSc.put(vs.Related_PGi_Vendor__c,vs.Id);
                  }     
            }
            List<Vendor_Scorecard__c> lstVSInsert = new List<Vendor_Scorecard__c>();
            ListV = [SELECT Id FROM PGi_Vendor_List__c WHERE Show_on_Surveys__c = true and Id NOT IN: mapVenSc.keySet() and ID IN:setVids];
            String ftDate = ScoreCardController.calculateStartEndDate(monthSortName, true);
            String edDate = ScoreCardController.calculateStartEndDate(monthSortName, false);


            //pull back relevant cases
            String caseQuery = 'SELECT Id, Status, Subject, X3rd_Party_Vendor__c, X3rd_Party_Vendor_2__c, X3rd_Party_Vendor_3__c FROM Case WHERE Status = \'Closed\' AND (X3rd_Party_Vendor__c IN: ListV OR X3rd_Party_Vendor_2__c IN: ListV OR X3rd_Party_Vendor_3__c IN: ListV) and  (ClosedDate >=:ftDate and ClosedDate <=:edDate)';
            Map<Id, Boolean> hasCaseByVendorId = new Map<Id, Boolean>();
            for(Case c: (List<Case>)Database.query(caseQuery)) {
                  Id first = c.X3rd_Party_Vendor__c;
                  Id second = c.X3rd_Party_Vendor_2__c;
                  Id third = c.X3rd_Party_Vendor_3__c;
                  if(first != null && hasCaseByVendorId.get(first) == null) {
                        hasCaseByVendorId.put(first, true);
                  }
                  if(second != null && hasCaseByVendorId.get(second) == null) {
                        hasCaseByVendorId.put(second, true);
                  }
                  if(third != null && hasCaseByVendorId.get(third) == null) {
                        hasCaseByVendorId.put(third, true);
                  }
            }
            if(ListV!= null && ListV.size()>0){
                  for(PGi_Vendor_List__c vl : ListV){
                        if(hasCaseByVendorId.get(vl.Id) != null && hasCaseByVendorId.get(vl.Id) == true) {
                              Vendor_Scorecard__c vs = new Vendor_Scorecard__c();
                              vs.Related_PGi_Vendor__c = vl.Id;
                              vs.Month_Year__c = urlEnds;
                              lstVSInsert.add(vs);
                        }
                  }     
            }
            if(lstVSInsert!= null && lstVSInsert.size()>0){
                  insert lstVSInsert;
                  insertedSize = lstVSInsert.size();
            }
            urlEnds = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/scorecard?data='+urlEnds;

        }
      } 
      global void finish(Database.BatchableContext BC){
            if(insertedSize == 0) { return; }
            List<ScorecardSurveyRecipients__c> ListCS = [SELECT id,Email__c FROM ScorecardSurveyRecipients__c WHERE Email__c != NULL];
            List<string> lstEmails = new List<string>();
            if(ListCS != Null && ListCS.size()>0){
                  for(ScorecardSurveyRecipients__c ec : ListCS){
                        lstEmails.add(ec.Email__c);
                  }
            }
            if(lstEmails!= null && lstEmails.size()>0 && urlEnds!= Null ){
			//List<EmailTemplate> et = [SELECT Id, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Scorecard_Survey_Alert'];                 
            //System.assert(et.size() > 0, 'No email template named Scorecard Survey Alert');
            	OrgWideEmailAddress[] owea = [SELECT Id  FROM OrgWideEmailAddress WHERE Address = 'pgisfnoreply@pgi.com'];
                  
            	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            	email.Subject = 'ALERT: Monthly Vendor Survey Request';
                  String body = 'Hello, \nPlease complete the Vendor Surveys for this month. Please follow this link to begin the survey process. \n' +urlEnds+'\nYou need to complete the survey for each active vendor in order to complete your round of surveys for the month.';
                  email.setToAddresses(lstEmails);
                  email.setPlainTextBody(body);
                  //email.setBody(body);
            	//email.setTemplateId(et[0].Id);  
                
            	//String here = '<a href="'+urlEnds+'">here</a>';
                  //String body = et[0].HTMLValue.replace('{here}', here);
              
            
              
                  
            if( owea.size() > 0 ) {
                  email.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            if(email!= Null){
                  Messaging.SendEmailResult[]  results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                  for(Messaging.SendEmailResult sr : results) {
                        if(!sr.isSuccess()){
                              System.debug(sr.isSuccess() + 'Send Email failed: ' + sr.getErrors()[0].getMessage());
                        }
                      
                  }
            }
           }
      }
        
    
}