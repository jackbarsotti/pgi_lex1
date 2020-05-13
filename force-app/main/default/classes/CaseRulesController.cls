public class CaseRulesController {
public Id recordid {get;set;}
    
    public CaseRulesController(ApexPages.StandardController controller) {
        recordid = controller.getId();
    }   
}