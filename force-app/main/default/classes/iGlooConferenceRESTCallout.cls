public class iGlooConferenceRESTCallout {

    @future(callout=true)
    public static void makeGETCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Datetime pastsixtymins = System.Now().addhours(-1);
        String DateStr = pastsixtymins.formatGmt('yyyy-MM-dd');
        String timeStr = pastsixtymins.formatGmt('HH:mm');
        Datetime currenttime = System.Now();
        String CurrentDateStr = currenttime.formatGmt('yyyy-MM-dd');
        String Currenttimestr = currenttime.formatGmt('HH:mm');
        //request.setEndpoint('https://event.mymeetingroom.com/Api/Search?ApiKey=salesforceintegration&LastModify='+datestr+'%20'+timestr+'&ResultsPerPage=1000');
        request.setEndpoint('https://event.mymeetingroom.com/Api/Search?ApiKey=salesforceintegration&LastModify='+datestr+'%20'+timestr+'&LastModifyTo='+Currentdatestr+'%20'+Currenttimestr+'&ResultsPerPage=1000');
        //request.setEndpoint('https://event.mymeetingroom.com/Api/Search?ApiKey=salesforceintegration&LastModify=2017-09-19%2017:00&LastModifyTo=2017-09-19%2022:00&ResultsPerPage=1000');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If successful connection is established
        if (response.getStatusCode() == 200) {
            Map<String, Object> fulldatamap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> Conferences = (List<Object>) fulldatamap.get('results');
            Set<String> allincomingconfinstanceids = new Set<String>();
            Map<String,Object> conferencemap = new Map<String,Object>();
            Map<String,Date> confstartdatemap = New Map<String,Date>();
            if(!Conferences.isEmpty()){
            system.debug('ARC debug Number of records retrieved:'+Conferences.size());
            for(Object conf : Conferences){
                Map<String, Object> confrecord = (Map<String, Object>)conf;
                String starttime = (String)confrecord.get('Start');   
                String starttimeinsecs = starttime.split('\\(')[1].split('\\)')[0];
                Datetime startdttime = Datetime.newInstance(Long.valueOf(starttimeinsecs));
                system.debug('ARC debug starttime :'+starttime);
                system.debug('ARC debug startDate:'+startdttime);
                String lastmodify = (String)confrecord.get('LastModify');
                String lastmodifyinsecs = lastmodify.split('\\(')[1].split('\\)')[0];
                Datetime lastmodifytime = Datetime.newInstance(Long.valueOf(lastmodifyinsecs));
                system.debug('ARC debug LastModify:'+lastmodifytime);
                Datetime pastthreeyears = date.today().addyears(-3);
                system.debug('ARC debug three years:'+pastthreeyears);
                if(startdttime > pastthreeyears){
                    //String instanceid = (String)confrecord.get('InstanceId');
                    String conferenceid = (String)confrecord.get('ConferenceId');
                    confstartdatemap.put(conferenceid,startdttime.date());
                    conferencemap.put(conferenceid,conf);
                    allincomingconfinstanceids.add(conferenceid);         
                }    
            }
            
            system.debug('ARC debug allincomingids:'+allincomingconfinstanceids);   
                 
            Set<String> confidstoupdate = new Set<String>();
            Set<String> confidstocreate = new Set<String>(); 
            Id rtid = Schema.SObjectType.PGi_Conference__c.getRecordTypeInfosByName().get('iGloo Conference').getRecordTypeId();   
            if(!allincomingconfinstanceids.isEmpty()){
                List<PGi_Conference__c> existingigloolist = [SELECT id,name FROM PGi_Conference__c where Name IN :allincomingconfinstanceids AND RecordType.Name LIKE '%iGloo%'];
                if(existingigloolist.isEmpty())
                    confidstocreate.addall(allincomingconfinstanceids);
                else
                {
                    for(PGi_Conference__c iglooconf : existingigloolist){
                        confidstoupdate.add(iglooconf.name);}
                    for(String str : allincomingconfinstanceids){
                        if(!confidstoupdate.contains(str))
                            confidstocreate.add(str);
                    }
                }           
            }  
            system.debug('ARC debug confidstocreate:'+confidstocreate);
            system.debug('ARC debug confidstoupdate:'+confidstoupdate);
            
            // Creating new conference records
            List<PGi_Conference__c> conflisttocreate = new List<PGi_Conference__c>();
            if(!confidstocreate.isEmpty()){
            for (String newstr : confidstocreate)
            {
                Map<String, Object> newconf = (Map<String,Object>) conferencemap.get(newstr);
                PGi_Conference__c confrectocreate = new PGi_Conference__c();
                confrectocreate.Name = (String)newconf.get('ConferenceId');
                confrectocreate.Conference_Date__c = confstartdatemap.get(confrectocreate.name);
                confrectocreate.ConferenceTitle__c = (String)newconf.get('Title');
                confrectocreate.Bridge_Name__c = (String)newconf.get('BridgeId');
                confrectocreate.ConferenceType__c = (String)newconf.get('ConferenceType');
                confrectocreate.Client_ID__c = (String)newconf.get('ModeratorId');
                confrectocreate.Moderator_Name__c = (String)newconf.get('ModeratorName');
                confrectocreate.Moderator_Passcode__c = (String)newconf.get('ModeratorPasscode');
                confrectocreate.Participant_Passcode__c = (String)newconf.get('ParticipantPasscode');
                confrectocreate.RecordTypeId = rtid;
                conflisttocreate.add(confrectocreate);
            }
            }
            //Updating existing conference records
            List<PGi_Conference__c> conflisttoupdate = new List<PGi_Conference__c>();
            if(!confidstoupdate.isEmpty()){
            conflisttoupdate = [SELECT id,name,ConferenceTitle__c,Client_ID__c,Conference_Date__c,Bridge_Name__c,ConferenceType__c,Moderator_Name__c,Moderator_Passcode__c,Participant_Passcode__c FROM PGi_conference__c where Name IN :confidstoupdate AND RecordType.Name LIKE '%iGloo%'];
            for (PGi_Conference__c ic : conflisttoupdate)
            {
                Map<String, Object> existingconf = (Map<String,Object>) conferencemap.get(ic.name);
                ic.ConferenceTitle__c = (String)existingconf.get('Title');
                ic.Conference_Date__c = confstartdatemap.get(ic.name);
                ic.Bridge_Name__c = (String)existingconf.get('BridgeId');
                ic.ConferenceType__c = (String)existingconf.get('ConferenceType');
                ic.Moderator_Name__c = (String)existingconf.get('ModeratorName');
                ic.Client_ID__c = (String)existingconf.get('ModeratorId');
                ic.Moderator_Passcode__c = (String)existingconf.get('ModeratorPasscode');
                ic.Participant_Passcode__c = (String)existingconf.get('ParticipantPasscode');
                ic.RecordTypeId = rtid;
            }
            }
            if(!conflisttocreate.isEmpty())
                insert conflisttocreate;    
            if(!conflisttoupdate.isEmpty())
                update conflisttoupdate;   
        } 
        }   
      }
}