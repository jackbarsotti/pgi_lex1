@isTest

public class PGI_ResourceCalendar_Controller_Test {



    @isTest static void PGI_ResourceCalendar_Controller_Test_Run () {
    
    
        PGI_ResourceCalendar_Controller rcA = new PGI_ResourceCalendar_Controller();
 
        ApexPages.StandardController stdController;
        
        PGI_ResourceCalendar_Controller rcB = new PGI_ResourceCalendar_Controller(stdController);
        string results = rcB.getAllEventsJson();
        results = rcB.getAllEventsJson();
        
          ServiceResource objResource = rcB.objResource;
    
       Boolean includeMyEvents = rcB.includeMyEvents;
       Integer refreshInterval = rcB.refreshInterval;
       Integer slotDuration = rcB.slotDuration;
        
        }
        
        


}