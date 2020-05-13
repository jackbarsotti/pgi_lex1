@IsTest
public class SubmitFinReqControllerTest {
    
    static testMethod void testController() {
        
        SubmitFinReqController objFinReqCtrl = new SubmitFinReqController();
        
        PageReference objPageRef = objFinReqCtrl.submitFinReq();
    }
    
}