public with sharing class OpportunityProductExtension {


	//expose public property, this property will be listing each layout section
	public List<LayoutDescriberHelper.LayoutSection> layoutSections {get;set;}
	public Id oppId {get; set;}
	public Opportunity oppty {get {
		return [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id =: oppId];
	} set;}
	public String opptyRecordTypeName {get {
		if(oppty == null && opptyRecordTypeName == null) {
			return 'Default';
		} else if (opptyRecordTypeName == null) {
			
			opptyRecordTypeName = oppty.RecordType.DeveloperName;
		}
		return opptyRecordTypeName;
	} set;}


	//public List<Schema.FieldSetMember> fieldSet(String fieldSetName, String ObjectName) {
	//    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	//    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	//    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

	//    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
	//    if(fieldSetObj == null) {
	//    	fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('PGi_Opportunity');
	//    }
	//    return fieldSetObj.getFields(); 
	//}  
	public List<Schema.FieldSetMember> fieldSet { get {
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('OpportunityLineItem');
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(opptyRecordTypeName);
	    if(fieldSetObj == null) {
	    	fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('Default');
	    }
	    return fieldSetObj.getFields(); 
	}}
	public OpportunityProductExtension(ApexPages.StandardController controller) {
		// Create list of fields to add to controller for object     
		/* dynamically get all fields for the Account object and add them to the controller */
    	List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().fields.getMap().keyset());		

		// Add fields to controller. This is to avoid the SOQL error in visualforce page
		if (!Test.isRunningTest())
		controller.addFields(fieldList);

		OpportunityLineItem oli = (OpportunityLineItem)controller.getRecord();
		//if(oli != null && oli.Id != null) {
		//	recordId = oli.Id;
		//}
		if(oli != null && oli.OpportunityId != null) {
			oppId = oli.OpportunityId;
		}
		

		sObject obj = controller.getRecord();
		/************************************************************************/
		 //getting the default record type
		//if we want an specific layout we must provide the appropriate record type id
		//id theRecordTypeIdToDescribe = LayoutDescriberHelper.getDefaultRecordType(obj);
		        
		//get the layout section items

		//TODO - HTML parse spaces and special characters
		//TODO - pull correct page layout name from oppty record type
		/***************************************************************************/
	}

}