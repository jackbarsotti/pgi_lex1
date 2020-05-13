/**  
* \arg ClassName        : MatchingServiceController_Test
* \arg JIRATicket       : 
* \arg CreatedOn        : 02/April/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Anup
* \arg ModifiedBy       : 
* \arg Description      : Test class for MatchingServiceController class
*/
@isTest
private class MatchingServiceController_Test {
    
    static testMethod void getCurrentPageId() {
        
        Account objAcc = new Account(Name = 'United_Oil');
        INSERT objAcc;
        
         ApexPages.StandardController sc = new ApexPages.StandardController(objAcc);
     	MatchingServiceController msController = new MatchingServiceController(sc);
    }
    
}