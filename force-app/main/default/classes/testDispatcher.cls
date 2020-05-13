@isTest
private class testDispatcher {
    
    private static ApexPages.StandardController controller;
    private static ApexPages.StandardSetController setcontroller;    
    
    static{
        PGITestUtilities.disableSalesWings();
        controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Contact(), MockContact.getNewContact().id));
        setcontroller = new ApexPages.StandardSetController(RTDatabaseUtils.getSObjectList(new Contact(), 'where id = \''+MockContact.getNewContact().id+'\''));
	}
    
    static testMethod void testConstruct() {
        
        Dispatcher d = new Dispatcher(controller);
        System.assert(d.dispatch()!=null);       
        
        d = new Dispatcher(setController);
        System.assert(d.dispatch()!=null);
        
        d = new Dispatcher(new Map<String, String>{'Contact' => '/apex/Contact'});
        System.assert(d.dispatch()==null);

        // for calling setCurrentPage()
        d = new Dispatcher(controller);
        PageReference currentPage = ApexPages.currentPage();
        d.setCurrentPage(currentPage);
        
        // for calling setObjectToControllerMapping()
        d = new Dispatcher(new Map<String, String>{'Contact' => '/apex/Contact'});
        System.assert(d.dispatch()==null);
        d.setObjectToControllerMapping(new Map<String, String>{'Contact' => '/apex/Contact'});
       
        // for calling setAdditionalPageParameters()
        d.setAdditionalPageParameters(new Map<String, String>{'Contact' => '/apex/Contact'});
    }
}