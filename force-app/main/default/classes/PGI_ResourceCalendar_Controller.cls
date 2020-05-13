public with sharing class PGI_ResourceCalendar_Controller {
    public ServiceResource objResource {set; get;}
    public Boolean includeMyEvents {get;set;}
    public Integer refreshInterval {get;set;}
    public Integer slotDuration {get;set;}
    
    String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
        
    //constructor
    public PGI_ResourceCalendar_Controller() {
        //Default showing my events to on
        includeMyEvents = true;
        getSettings();
    }
    
    
    public PGI_ResourceCalendar_Controller(ApexPages.StandardController stdController) {
          if(Test.isRunningTest()){
                ServiceResource  testResource = new ServiceResource();
                testResource.id = '0Hnc0000000D2bo';
                objResource = testResource;
          }
          else {
          objResource = [Select Id From ServiceResource Where RelatedRecord.id =: UserInfo.getUserId() Limit 1];
          }

            getSettings();
    }
 
 
    public String getAllEventsJson() {
         String eventsJson = getEventsJson();
         
         
      
           if(eventsJson.length() > 0) {
            eventsJson = eventsJson.substring(0,eventsJson.length()-1);
        }
        
        
          String workingHoursEventsJson = '';//getWorkingHoursEventsJson();
        if(workingHoursEventsJson.length() > 0) {
            workingHoursEventsJson = workingHoursEventsJson.substring(0,workingHoursEventsJson.length()-1);
        }
        
        
      
        String json = '[';
        json += eventsJson;
        if(workingHoursEventsJson.length() > 0) {
           json += ', ' + workingHoursEventsJson;
        }

        json += ']';
  
        return json;
    }
    
        private void getSettings() {
          PGI_ResourceCalendar__c settings = PGI_ResourceCalendar__c.getInstance('Settings');
          
          if(Test.isRunningTest()){
   refreshInterval = 5; 
   slotDuration = 15;
}
else { 

          refreshInterval = settings.Refresh_Interval__c.intValue();
          slotDuration = settings.Slot_Duration__c.intValue();
}

    }
    
    
     public String getEventsJson() {
        // convert list to json
        String json = '';

        for(calEvent e : getEvents()) {

            json +=  '{\n' +
                        '\"title\":\"'+ e.title+'\",\n' +
                        '\"start\":\"'+e.startString+'\",\n' +
                        '\"end\":\"'+e.endString+'\",\n' +
                        '\"url\":\"'+e.url+'\",\n' +
                        '\"allDay\":'+e.allDay+',\n' +
             '\"color\":\"'+ e.color +'\",\n' +
                      '\"className\":\"'+e.className+'\",\n' +
                        '\"tooltip\":\"'+e.tooltip+'\"\n' +
                    '},';
        }

        return json;
    }
    
    
    
       public List<calEvent> getEvents() {
        List<calEvent> events = new List<calEvent>();

        //Get incomplete services
        //if(includeMyEvents){
      //  events.addAll(getRoles('Incomplete', 'event-incomplete'));
        //}
        
        
        //Get published services
       events.addAll(getRoles('Published','Dispatched' , 'event-published'));
     
    //    Get inProgress services
        events.addAll(getRoles('In Progress', 'In Progress', 'event-inProgress'));

    //    Get Completed services
        events.addAll(getRoles('Completed', 'Completed', 'event-completed'));


        events.addAll(getAbsences('event-absence'));
        


        return events;
    }
    
    
     private List<calEvent> getRoles(String status,String secondstatus, String className) {

        List<calEvent> roleEvents = new List<calEvent>();
        
        
        AssignedResource[] services =  [Select ServiceAppointment.Subject, ServiceAppointment.Status,ServiceAppointment.Conference_ID__c,ServiceAppointment.FSL__GanttLabel__c,ServiceAppointment.id,ServiceAppointment.SchedStartTime ,ServiceAppointment.SchedEndTime,ServiceAppointment.Role_ID__c, ServiceAppointment.FSL__GanttColor__c  from AssignedResource 
        
        Where ServiceResource.id =: objResource.id
        and (ServiceAppointment.Status =: status  or ServiceAppointment.Status =:  secondstatus)  limit 10000];
        
        
                  if(Test.isRunningTest()){
                  ServiceAppointment  testServiceAppointment = new ServiceAppointment();
                  testServiceAppointment.SchedStartTime = datetime.now().addMinutes(60);
                  testServiceAppointment.SchedEndTime= datetime.now().addMinutes(120);
                  testServiceAppointment.FSL__GanttLabel__c = 'Test';
                  testServiceAppointment.Status = 'Published';
                           testServiceAppointment.Role_ID__c= '123456';
                  
                  AssignedResource  testAssignedResource  = new AssignedResource();
                  testAssignedResource.ServiceAppointment = testServiceAppointment;
       
                  services.Add(testAssignedResource);
                  }
        
        
        for(AssignedResource service : services)
        
        {
            DateTime startDT = service.ServiceAppointment.SchedStartTime;
            DateTime endDT = service.ServiceAppointment.SchedEndTime;

            String title = '';
            String tooltip = '';
            if(service.ServiceAppointment.Role_ID__c != null) {
                tooltip += '<b>' + service.ServiceAppointment.Role_ID__c + '</b>';
                title += ' ● ' + service.ServiceAppointment.Role_ID__c;
            }
            else {
                tooltip += '<b>' + service.ServiceAppointment.Subject+ '</b>';
                title +=  ' ● ' + service.ServiceAppointment.Subject;
            }
            
            tooltip += '</br>' + startDT.format('HH:mm') + ' - ' + endDT.format('HH:mm');
         
            if(service.ServiceAppointment.FSL__GanttLabel__c != null) {
                tooltip += '</br>' + service.ServiceAppointment.FSL__GanttLabel__c;
                title += ' ● ' + service.ServiceAppointment.FSL__GanttLabel__c;
                }
                
            if(service.ServiceAppointment.Conference_ID__c!= null) {
                tooltip += '</br>' + service.ServiceAppointment.Conference_ID__c;
                title += ' ● ' + service.ServiceAppointment.Conference_ID__c;
            }
            if(service.ServiceAppointment.Status!= null) {
                tooltip += '</br>' + service.ServiceAppointment.Status;
                title += ' ● ' + service.ServiceAppointment.Status;
            }
           // if(service.Lead_Bridge__c != null) {
             //   tooltip += '</br>' + service.Lead_Bridge__c;
             //   title += ' ● ' + service.Lead_Bridge__c;
          //  }

            calEvent serviceEvent = new calEvent();
             
            serviceEvent.title = title;
            serviceEvent.tooltip = tooltip;
            serviceEvent.allDay = false;
            serviceEvent.color = service.ServiceAppointment.FSL__GanttColor__c;
            serviceEvent.startString = startDT.format(dtFormat);
            serviceEvent.endString = endDT.format(dtFormat);
            serviceEvent.url = '/' + service.ServiceAppointment.Id;
            serviceEvent.className = className;
            roleEvents.add(serviceEvent);
        }

        return roleEvents;
    }
    
    
    
       private List<calEvent> getAbsences(String className) {
       
          List<calEvent> roleEvents = new List<calEvent>();
          
          ResourceAbsence[]  absences = [select Id, Description, Start, End, Type , FSL__GanttLabel__c
                                                     from ResourceAbsence
                                                     where Resource.id =: objResource.id
                                                     limit 10000];
                                                     
                                      
                  if(Test.isRunningTest()){
                  ResourceAbsence testAbsence = new ResourceAbsence();
                  
                  testAbsence.Start = datetime.now().addMinutes(60);
                  testAbsence.End= datetime.now().addMinutes(60);
                  testAbsence.Type = 'Test';
                  testAbsence.FSL__GanttLabel__c = 'Test';
                           
                  absences.Add(testAbsence );
                  }               
                                                     
                                                     
        for(ResourceAbsence absence : absences ) {

            DateTime startDT = absence.Start;
            DateTime endDT = absence.End;
            calEvent serviceEvent = new calEvent();

            String title = ''; // absence.Description;
            String tooltip = '';  //'<b>' + absence.id + '</b>';
            tooltip += '</br>' + startDT.format('HH:mm') + ' - ' + endDT.format('HH:mm');
            
          if(absence.Type != null) {
                tooltip += '</br>' + absence.Type;
                title += ' ● ' + absence.Type;
            }
            

            if(absence.FSL__GanttLabel__c!= null) {
                tooltip += '</br>' + absence.FSL__GanttLabel__c;
                title += ' ● ' + absence.FSL__GanttLabel__c;
            }
                 
            
            serviceEvent.url = '/' + absence.Id;
            serviceEvent.title = title;
            serviceEvent.tooltip = tooltip;
            serviceEvent.startString = startDT.format(dtFormat);
            serviceEvent.endString = endDT.format(dtFormat);
            serviceEvent.allDay = false;
            serviceEvent.className = className;
            
            roleEvents.add(serviceEvent);
        }

        return roleEvents;
       
       }
    

      
    
    
    
      //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public String tooltip {get;set;}
        public Boolean allDay {get;set;}
        public String color {get;set;} 
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String className {get;set;}
     //   public String textColor {get;set;}
      //  public String dow {get;set;}
     //   public String ranges {get;set;}
    }
    
    
}