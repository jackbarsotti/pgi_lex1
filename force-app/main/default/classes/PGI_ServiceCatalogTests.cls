@isTest
private class PGI_ServiceCatalogTests
{
    @isTest
    static void testCatalogTrigger() {
        PGi_ServiceCatalog_Category__c cat = createCategory();
        boolean failure = false;
        try {
            PGi_ServiceCatalog_Category_Option__c option = createCategoryOption(cat, 'nosuchobject');
        } catch (exception e) {
            failure = true;
        }
        system.assert(failure, 'Expected to fail on bad sojbect name');
        failure = false;
        
        PGi_ServiceCatalog_Category_Option__c option = createCategoryOption(cat, 'Case');
        
        try {
            PGi_ServiceCatalog_Hidden_Input_Value__c input = createHiddenInput(option, 'nosuchfield');
        } catch (exception e) {
            failure = true;
        }
        system.assert(failure, 'Expected to fail on bad sojbect field name');
        failure = false; 
        
        PGi_ServiceCatalog_Hidden_Input_Value__c input = createHiddenInput(option, 'Status');
        
        try {
            system.debug('==cat===>');
            PGi_ServiceCatalog_Section__c section = createSection(option, 'invalid_name');
            system.debug('==cat===>');
        } catch (exception e) {
            failure = true;
        }
        system.assert(failure, 'Section insert fails without valid field set');
        
        PGi_ServiceCatalogController controller = new PGi_ServiceCatalogController();
        List<PGi_ServiceCatalog_Section__c> sectionList = controller.displaySectionList;
        system.assert(sectionList.size() == 0);
        List<PGi_ServiceCatalog_Category_Option__c> catOptionList =  controller.displayCategoryOptionList;
        system.assert(catOptionList.size() == 0);
        controller.home();
        controller.fieldSetList('Case');
        controller.saveServiceCatalog();
        controller.selectedCategoryId 		= cat.Id;
        controller.rerender();
        /* test re-rendering of category options */
        catOptionList =  controller.displayCategoryOptionList;
        system.assert(catOptionList.size() == 1); 
        controller.selectedCategoryId = cat.Id;
        controller.cancel();
        
        system.assert(controller.selectedCategoryId == null);
        catOptionList =  controller.displayCategoryOptionList;
        system.assert(catOptionList.size() == 0); 
        
        
        controller.selectedCategoryId = cat.Id;
        controller.selectedCategoryOptionId = option.Id;
        system.assert(controller.allowSave == true);
        //controller.populateHiddenValues();
        controller.saveServiceCatalog();
        
        Case c = [Select Id FROM Case];
        
        Map<Id, List<Schema.FieldSetMember>> sectionfields = controller.sectionIdToFields;
        system.assert(null == controller.nullValue);
        system.assert(controller.theRecord != null);
        controller.cancel();
        
        system.assert(controller.theRecord == null);
        controller.navigateToRecord();
    }
    static testMethod void testCatogeryListError(){
        PGi_ServiceCatalogController controller = new PGi_ServiceCatalogController();
        List<PGi_ServiceCatalog_Category__c> categoryList =  controller.categoryList; 
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
        String baseUrl = controller.baseUrl;
        System.assertequals(0,controller.fieldSetList('text').size());
        Boolean allowSave =controller.allowSave;
        System.assertEquals(false, allowSave);
    }
    static testMethod void testCatogeryList(){
        PGi_ServiceCatalog_Category__c cat = createCategory();
        cat.Navigate_to__c='google.com';
        Update cat;
        PGi_ServiceCatalog_Category_Option__c option = createCategoryOption(cat, 'Case');
        ApexPages.currentPage().getParameters().put('category',cat.Id);
        ApexPages.currentPage().getParameters().put('categoryOption',option.Id);
        PGi_ServiceCatalogController controller = new PGi_ServiceCatalogController();
        List<PGi_ServiceCatalog_Category__c> categoryList =  controller.categoryList; 
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
        String baseUrl = controller.baseUrl;
        System.assertequals(0,controller.fieldSetList('text').size());
        Boolean allowSave =controller.allowSave;
        System.assertEquals(true, allowSave);
        controller.rerender();
    }
    //to cover selectedCategoryOption
    static testMethod void testCatogeryListrerender(){
        PGi_ServiceCatalog_Category__c cat = createCategory();
        cat.Navigate_to__c=null;
        Update cat;
        PGi_ServiceCatalog_Category_Option__c option = createCategoryOption(cat, 'Case');
        option.Navigate_to__c ='https://google.com';
        Update option;   
        PGi_ServiceCatalog_Section__c section = createSection(option, 'PGi_Client_Billing_Help_Desk');
        ApexPages.currentPage().getParameters().put('category',cat.Id);
        ApexPages.currentPage().getParameters().put('categoryOption',option.Id);
        PGi_ServiceCatalogController controller = new PGi_ServiceCatalogController();
        List<PGi_ServiceCatalog_Category__c> categoryList =  controller.categoryList; 
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
        String baseUrl = controller.baseUrl;
        System.assertequals(0,controller.fieldSetList('text').size());
        List<PGi_ServiceCatalog_Section__c> displaySectionList = controller.displaySectionList;
        controller.rerender();
        Map<Id, List<Schema.FieldSetMember>> sectionIdToFields = controller.sectionIdToFields;
        Boolean allowSave =controller.allowSave;
        System.assertEquals(true, allowSave);
        ApexPages.currentPage().getParameters().put('devPreview','test');
        controller.home();
        sObject theRecord =controller.theRecord;
        theRecord=section;
        controller.navigateToRecord(); 
    }
    //to cover selectedCategoryOption
    static testMethod void testCatogeryListrerenderelse(){
        PGi_ServiceCatalog_Category__c cat = createCategory();
        cat.Navigate_to__c=null;
        Update cat;
        PGi_ServiceCatalog_Category_Option__c option = createCategoryOption(cat, 'Case');
        option.Navigate_to__c ='google.com';
        Update option;     
        ApexPages.currentPage().getParameters().put('category',cat.Id);
        ApexPages.currentPage().getParameters().put('categoryOption',option.Id);
        PGi_ServiceCatalogController controller = new PGi_ServiceCatalogController();
        List<PGi_ServiceCatalog_Category__c> categoryList =  controller.categoryList; 
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
        String baseUrl = controller.baseUrl;
        String rerender = controller.rerender;
        System.assertequals(0,controller.fieldSetList('text').size());
        controller.rerender();
        Boolean allowSave =controller.allowSave;
        System.assertEquals(true, allowSave);
        
    }
    private static PGi_ServiceCatalog_Category__c createCategory() {
        PGi_ServiceCatalog_Category__c cat = new PGi_ServiceCatalog_Category__c(Active__c = true, Navigate_to__c ='https://google.com');
        insert cat; 
        system.debug('==cat===>'+cat);
        return cat; 
    }
    private static PGi_ServiceCatalog_Category_Option__c createCategoryOption(PGi_ServiceCatalog_Category__c category, String apiName) {
        PGi_ServiceCatalog_Category_Option__c option = new PGi_ServiceCatalog_Category_Option__c(Category__c = category.Id, Object_API_Name__c = apiName, Active__c = true);
        insert option;
        return option;
    }
    private static PGi_ServiceCatalog_Section__c createSection(PGi_ServiceCatalog_Category_Option__c option, String apiName) {
        PGi_ServiceCatalog_Section__c section = new PGi_ServiceCatalog_Section__c(Category_Option__c = option.Id, Field_Set_API_Name__c = apiName);
        insert section;
        system.debug('=section==>'+section);
        return section;
    }
    private static PGi_ServiceCatalog_Hidden_Input_Value__c createHiddenInput(PGi_ServiceCatalog_Category_Option__c option, String apiName) {
        PGi_ServiceCatalog_Hidden_Input_Value__c input = new PGi_ServiceCatalog_Hidden_Input_Value__c(Category_Option__c = option.Id, Field_API_Name__c = apiName, Set_Value__c = 'New');
        insert input;
        return input;
    }
}