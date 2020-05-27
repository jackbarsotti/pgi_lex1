public with sharing class GenerateNCSController {
    @AuraEnabled
    public static Opportunity getOpportunityData(String oppId){
        Id profileId= userinfo.getProfileId();
        Id userId = userinfo.getUserId();
        Opportunity oppRecord = new Opportunity();
        String userRegion = [SELECT User_Region__c from User WHERE Id =: userId].User_Region__c;
        Set<String> profileIdSet = new Set<String>();
        for(Profile profileRec : [SELECT Id
                                  FROM Profile
                                  WHERE Name = 'System Administrator' OR Name = 'PGi Implementation Services']){
                                      profileIdSet.add(profileRec.Id);
                                  }
        if(profileIdSet.contains(profileId)){
            oppRecord = [SELECT StageName FROM Opportunity WHERE id =: OppId];
        }
        return oppRecord;
    }
    @AuraEnabled
    public static String getOpportunityStageName(String oppId){
        String Stage = '';
        List<OpportunityLineItem> lineItemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:oppId];
        if(lineItemList.size() >= 1){
            Stage = [SELECT StageName FROM Opportunity WHERE id =: OppId].StageName;
        }
        return Stage;
    }
    @AuraEnabled
    public static iContract_Custom_Settings__c getCustomSetting(){
        return iContract_Custom_Settings__c.getInstance();
    }
    
}