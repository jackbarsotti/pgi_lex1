public class CampaignTriggerHandler extends TriggerHandler{
    public CampaignTriggerHandler() {
        super('CampaignTriggerHandler');
    }
    protected override void afterInsert(){
        setStatusofCampaignMember();
    }
    
    private void setStatusofCampaignMember() {
        Boolean boolValue;//Any 1 labels Hasresponded anf isDefault should be true
        Map<String,List<String>> typeToStatusMap = getMemberStatus();
        List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
        Map<Id,String> campaignToTypeMap = new Map<Id,String>();
        for(Campaign camp : (List<Campaign>)Trigger.new){
            campaignToTypeMap.put(camp.Id,camp.Type);
        }  
        System.debug('>>> campaignToTypeMap >>>'+campaignToTypeMap);
        System.debug('>>> campaignToTypeMap.keySet() >>>'+campaignToTypeMap.keySet());
        
        Map<Id, List<CampaignMemberStatus>> campignStatusMap = new Map<Id, List<CampaignMemberStatus>> ();
        for (CampaignMemberStatus cm: [Select Id, Label, CampaignID  FROM CampaignMemberStatus WHERE CampaignID IN :campaignToTypeMap.keySet()]){
            System.debug('>>> cm >>>'+cm);
            if (campignStatusMap.containsKey (cm.CampaignID)) {
                campignStatusMap.get (cm.CampaignID).add (cm);
            } else {
                campignStatusMap.put (cm.CampaignID, new List< CampaignMemberStatus> {cm});
            }
        }
        Set<String> statusValues = new Set<String>();
        Set<String> remvovedValues = new Set<String>();
        List<CampaignMemberStatus> todelete =new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> toInsert =new List<CampaignMemberStatus>();
        for (Id eachId : campaignToTypeMap.keySet ()) {
            String campaignTypeLst = campaignToTypeMap.get(eachId);
            System.debug('>>> campaignTypeLst >>> '+campaignTypeLst);
            System.debug('>>> eachId >>> '+eachId);
            if(typeToStatusMap.containsKey(campaignTypeLst)){
                statusValues = new Set<String>(typeToStatusMap.get(campaignTypeLst));
            }
            else{
                statusValues = new Set<String>(typeToStatusMap.get('All'));
            }
            if(campignStatusMap.get(eachId) != null) {
                for (CampaignMemberStatus eachStatus : campignStatusMap.get (eachId)) {
                    if (statusValues.contains (eachStatus.Label)) {
                        statusValues.remove (eachStatus.label);
                        remvovedValues.add(eachStatus.label);
                    }
                    else{
                        todelete.add(eachStatus);
                    }
                }
            }
            Integer i =0;
            for(String picklistValue : statusValues){
                i=i+1;
                if(remvovedValues.isEmpty() && i == 1){//if both responded and Sent is Deleted
                    CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId = eachId, HasResponded=true, Label = picklistValue,IsDefault=true);
                    toInsert.add(cms);
                }
                //Sent is Deleted 
                if(remvovedValues.contains('Responded') && !remvovedValues.contains('Sent') && i == 1){
                    CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId = eachId, HasResponded=false, Label = picklistValue,IsDefault=true);
                    toInsert.add(cms);
                }
                //Responded is deleted
                if(!remvovedValues.contains('Responded') && remvovedValues.contains('Sent') && i == 1){
                    CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId = eachId, HasResponded=true, Label = picklistValue,IsDefault=false);
                    toInsert.add(cms);
                }
                //Both are not Deleted
                System.debug('Testing'+(remvovedValues.contains('Responded') && remvovedValues.contains('Sent') && i == 1));
                if(i > 1 || (remvovedValues.contains('Responded') && remvovedValues.contains('Sent') && i == 1)){
                    CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId = eachId, HasResponded=false, Label = picklistValue,IsDefault=false);
                    toInsert.add(cms);
                }
            }
        }
        //insert should be first.
        if(!toInsert.isEmpty()){
            Database.insert(toInsert, false);
        }
        if(!toDelete.isEmpty()){
            Database.delete(toDelete, false);
        }
        
        
    }
    
    public static Map<String,List<String>> getMemberStatus(){
        Map<String,List<String>> typeToStatusMap = new Map<String,List<String>>();
        for(CampaignMember_Status__mdt campaignMemberMtd :[SELECT Id,MasterLabel,Status__c	 
                                                           FROM CampaignMember_Status__mdt]){
                                                               String statusStr = campaignMemberMtd.Status__c;
                                                               List<String> statusLst = statusStr.split(';');
                                                               typeToStatusMap.put(campaignMemberMtd.MasterLabel,statusLst);
                                                           }
        System.debug('>> typeToStatusMap >>'+typeToStatusMap);
       // System.debug('>> campaignMemberMtd >>'+campaignMemberMtd);
        return typeToStatusMap;
    }
}