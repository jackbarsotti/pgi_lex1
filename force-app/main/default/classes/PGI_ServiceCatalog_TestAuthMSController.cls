@isTest
private class PGI_ServiceCatalog_TestAuthMSController {

    static testMethod void myUnitTest() {
        //Test.setCurrentPage(Page.PGI_ServiceCatalogPage);
        PGI_ServiceCatalogController pscc = new PGI_ServiceCatalogController();
    	PGI_ServiceCatalog_ADAuthorization amc  = new PGI_ServiceCatalog_ADAuthorization(pscc);
    	amc.authMS();
    	
    	
    	Test.StartTest();

   		Test.setMock(HttpCalloutMock.class, new PGI_ServiceCatalog_MockMSController());
		amc.code='24d4eb8e-83d3-4f59-9c34-bee10289b1ac';
    	amc  = new PGI_ServiceCatalog_ADAuthorization(pscc);
    	amc.code='24d4eb8e-83d3-4f59-9c34-bee10289b1ac';
    	amc.authMS();
    	amc  = new PGI_ServiceCatalog_ADAuthorization(pscc);
    	amc.logout();
    	Test.StopTest();
     }
}