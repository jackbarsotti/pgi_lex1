@IsTest
public class SubmitMMHFinReqControllerTest {
    
    static testMethod void testController() {
        
        SubmitMMHFinReqController objFinReqCtrl = new SubmitMMHFinReqController();
        
        PageReference objPageRef = objFinReqCtrl.submitFinReq();
    }
    
}