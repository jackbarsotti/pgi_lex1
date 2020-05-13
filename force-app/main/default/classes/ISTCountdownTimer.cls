global with sharing class ISTCountdownTimer {

    public Implementation_Services__c ist {get;set;}
    private ApexPages.StandardController controller {get; set;}

    public ISTCountdownTimer(ApexPages.StandardController controller) {
        List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get('Implementation_Services__c').getDescribe().fields.getMap().keyset());       
        if(!Test.isRunningTest()){ 
            // Add fields to controller. This is to avoid the SOQL error in visualforce page
            controller.addFields(fieldList);
        }
        ist = (Implementation_Services__c)controller.getRecord();
    }

    public ISTCountdownTimer() { }


    global class ISTTimerWrapper {
        public String stage1Color {get;set;}
        public String stage2Color {get;set;}
        public String stage3Color {get;set;}
        public String stage1Time {get; set;}
        public String stage2Time {get; set;}
        public String stage3Time {get; set;}
                public Boolean stage1Complete {get; set;}
                public Boolean stage2Complete {get; set;}
                public Boolean stage3Complete {get; set;}
        public Boolean paused {get;set;}
        public ISTTimerWrapper(Id recordId) {
            Implementation_Services__c thisIst = [SELECT Id, Phase_1_Color__c, Phase_2_Color__c, Phase_3_Color__c, 
                                                    Date_of_Stage_Off_Hold__c, Date_of_Stage_On_Hold__c,
                                                   Phase_1_Days_Left__c,
                                                   Phase_2_Days_Left__c,
                                                   Phase_3_Days_Left__c,
                                                  Phase_1_Pause_Date__c,
                                                  Phase_2_Pause_Date__c,
                                                  Phase_3_Pause_Date__c
                             FROM Implementation_Services__c
                             WHERE Id = :recordId];
            this.stage1Complete = thisIst.Phase_1_Pause_Date__c != null;
            this.stage2Complete = thisIst.Phase_2_Pause_Date__c != null;
            this.stage3Complete = thisIst.Phase_3_Pause_Date__c != null;
            this.stage1Color = thisIst.Phase_1_Color__c;
            this.stage2Color = thisIst.Phase_2_Color__c;
            this.stage3Color = thisIst.Phase_3_Color__c;
            this.stage1Time = String.valueOf(thisIst.Phase_1_Days_Left__c);
            this.stage2Time = String.valueOf(thisIst.Phase_2_Days_Left__c);
            this.stage3Time = String.valueOf(thisIst.Phase_3_Days_Left__c);
            this.paused = thisIst.Date_of_Stage_On_Hold__c != null;
        }
    }
    @RemoteAction
    global static ISTTimerWrapper refreshTimers(String recordId) {
        System.debug(recordId);
        return new ISTTimerWrapper(recordId);
    }

}