@isTest
private class PicklistDescController_Test { 
 
	private static testMethod void testPickListDescController() {
        Id pgi_ClientESRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Client_External_Support').getRecordTypeId();
	   ApexPages.currentPage().getParameters().put('sobjectType', 'Case');
        ApexPages.currentPage().getParameters().put('recordTypeId', pgi_ClientESRTId);
        ApexPages.currentPage().getParameters().put('picklistFieldName', 'Status');
	    PickListDescController objListDesc = new PickListDescController();
        objListDesc.getPicklistValuesforRT();
        System.assertEquals('Status', objListDesc.pickListFieldName);
        String strobjc = ApexPages.currentPage().getParameters().get('sobjectType'); 
        Id cifxRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Client_External_Support').getRecordTypeId();
        PicklistDescriber.describe('Case',cifxRTId,'Status');
        System.debug('The value is'+objListDesc.sobj.get('RecordTypeId'));
        System.assertEquals(null, ApexPages.currentPage().getParameters().get('core.apexpages.devmode.url'));
        System.assertEquals(cifxRTId, objListDesc.sobj.get('RecordTypeId'));
    }
 }