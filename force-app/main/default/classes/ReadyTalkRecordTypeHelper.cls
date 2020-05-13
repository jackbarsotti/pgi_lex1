public without sharing class ReadyTalkRecordTypeHelper {
	//COD-1376
  	public static List<RecordType> readyTalkAccountRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '%ReadyTalk%'];
  	//COD-1376
  	public static Set<Id> readyTalkAccountRecordTypeIds {get{
	    if(readyTalkAccountRecordTypeIds == null) {
	      readyTalkAccountRecordTypeIds = new Set<Id>();
	      for(RecordType rt: readyTalkAccountRecordTypes) {
	        readyTalkAccountRecordTypeIds.add(rt.Id);
	      }
	    }
	    return readyTalkAccountRecordTypeIds;
    } set;}

	//COD-1376
  	public static List<RecordType> readyTalkCaseRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Case' AND Name LIKE '%ReadyTalk%'];
  	//COD-1376
  	public static Set<Id> readyTalkCaseRecordTypeIds {get{
	    if(readyTalkCaseRecordTypeIds == null) {
	      readyTalkCaseRecordTypeIds = new Set<Id>();
	      for(RecordType rt: readyTalkCaseRecordTypes) {
	        readyTalkCaseRecordTypeIds.add(rt.Id);
	      }
	    }
	    return readyTalkCaseRecordTypeIds;
    } set;}

	//COD-1376
  	public static List<RecordType> readyTalkContactRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name LIKE '%ReadyTalk%'];
  	//COD-1376
  	public static Set<Id> readyTalkContactRecordTypeIds {get{
	    if(readyTalkContactRecordTypeIds == null) {
	      readyTalkContactRecordTypeIds = new Set<Id>();
	      for(RecordType rt: readyTalkContactRecordTypes) {
	        readyTalkContactRecordTypeIds.add(rt.Id);
	      }
	    }
	    return readyTalkContactRecordTypeIds;
    } set;}

    //COD-1376
  	public static List<RecordType> readyTalkLeadRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name LIKE '%ReadyTalk%'];
  	//COD-1376
  	public static Set<Id> readyTalkLeadRecordTypeIds {get{
	    if(readyTalkLeadRecordTypeIds == null) {
	      readyTalkLeadRecordTypeIds = new Set<Id>();
	      for(RecordType rt: readyTalkLeadRecordTypes) {
	        readyTalkLeadRecordTypeIds.add(rt.Id);
	      }
	    }
	    return readyTalkLeadRecordTypeIds;
    } set;}

        //COD-1376
  	public static List<RecordType> readyTalkOpportunityRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name LIKE '%ReadyTalk%'];
  	//COD-1376
  	public static Set<Id> readyTalkOpportunityRecordTypeIds {get{
	    if(readyTalkOpportunityRecordTypeIds == null) {
	      readyTalkOpportunityRecordTypeIds = new Set<Id>();
	      for(RecordType rt: readyTalkOpportunityRecordTypes) {
	        readyTalkOpportunityRecordTypeIds.add(rt.Id);
	      }
	    }
	    return readyTalkOpportunityRecordTypeIds;
    } set;}

    public static List<RecordType> readyTalkCampaignRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Campaign' AND Name LIKE '%PGi%'];
    public static List<RecordType> readyTalkCampaignMemberRecordTypes = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'CampaignMember' AND Name LIKE '%PGi%'];
}