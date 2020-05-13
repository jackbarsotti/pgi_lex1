public class MatchingServiceController {
    
    public Id recordid {get;set;}
    
    public MatchingServiceController(ApexPages.StandardController controller) {
        //Account acc = new Account();
        recordid = controller.getId();
    }         
}