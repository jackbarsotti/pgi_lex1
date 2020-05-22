public with sharing class SendForESignatureController {
    @AuraEnabled
    public static Opportunity getOpportunityData(String oppId){
        Id profileId= userinfo.getProfileId();
        Opportunity oppRecord = new Opportunity();
        
        Set<String> profileIdSet = new Set<String>();
        for(Profile profileRec : [SELECT Id
                                  FROM Profile
                                  WHERE Name = 'System Administrator' OR Name = 'PGi Implementation Services']){
                                      profileIdSet.add(profileRec.Id);
                                  }
        if(profileIdSet.contains(profileId)){
            oppRecord = [SELECT StageName, Primary_Won_Reason__c, Secondary_Won_Reason__c, Tertiary_Won_Reason__c, Differentiating_Win_Factors__c,Incumbent__c,Competitor_s__c 
                         FROM Opportunity WHERE id =: OppId];
        }
        System.debug('>> oppRecord >>'+oppRecord);
        return oppRecord;
    }

    @AuraEnabled
    public static List<echosign_dev1__SIGN_Agreement__c> getSignAgreementData(String oppId){
        List<echosign_dev1__SIGN_Agreement__c> signObj = [SELECT id, Name, CreatedDate, ECHOSIGN_DEV1__STATUSVISIBLE__C 
                                                            FROM echosign_dev1__SIGN_Agreement__c 
                                                            WHERE ECHOSIGN_DEV1__OPPORTUNITY__C =: oppId and ECHOSIGN_DEV1__STATUSVISIBLE__C IN ('Draft', 'Pre-Send', 'Out for Signature', 'Waiting for Counter-Signature', 'Send in Progress', 'Waiting for Counter-Approval', 'Out for Approval', 'Created')];
        return signObj;
    }
    
    @AuraEnabled
    public static echosign_dev1__Agreement_Template__c getAgreementTemplateData(){
        Id userId = userinfo.getUserId();
        
        User userDetails =[SELECT Id, Name, Channel__c, User_Region__c, Country 
                            FROM User
                            WHERE Id=:userinfo.getUserId() ];
        System.debug('>> user details >>'+userDetails);
        String userChannel = userDetails.Channel__c;
        String userRegion ;//= userDetails.User_Region__c;
        String userCountry = userDetails.Country;
        
        if(userChannel == 'Partners' || userChannel == 'Carrier'){
            userRegion = 'Partners';
        }
        else{
            userRegion = 'EMEA';
        }
        echosign_dev1__Agreement_Template__c agreeTempObj = [SELECT Id, Name FROM echosign_dev1__Agreement_Template__c 
                                                    WHERE Name LIKE : '%'+ userRegion+'%' AND
                                                    echosign_dev1__Master_Object_Type__c = 'Opportunity'];
        System.debug('>> agreeTempObj >>'+agreeTempObj);
        return agreeTempObj;
    }
}