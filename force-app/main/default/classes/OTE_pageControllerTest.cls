/**  
* \arg ClassName        : OTE_pageControllerTest
* \arg JIRATicket       : 
* \arg CreatedOn        : 19/July/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Vijay
* \arg ModifiedBy       : 
* \arg Description      : Test class for OTE_pageController class
*/
@isTest
private class OTE_pageControllerTest {
    
    static testMethod void getCurrentPageId() {
        
        Account objAcc = new Account(Name = 'United_Oil');
        INSERT objAcc;
        
         ApexPages.StandardController sc = new ApexPages.StandardController(objAcc);
     	OTE_pageController oteController = new OTE_pageController(sc);
        
    }
    
}