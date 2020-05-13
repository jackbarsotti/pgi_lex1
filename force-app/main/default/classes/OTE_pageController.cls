public class OTE_pageController {
    
    public Id recordid {get;set;}
    
    public OTE_pageController(ApexPages.StandardController controller) {
        //Account acc = new Account();
        recordid = controller.getId();
    }         
}