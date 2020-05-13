/*********************************************************************
Name : CreateCampaignHistoryFromLead 
Description : Trigger on Lead for creating the Campaingn Member on leads.
**********************************************************************/
trigger CreateCampaignHistoryFromLead on Lead (after insert, after update) {
    //Identified that the trigger Enable/Disabled by User in custom setting 'Trigger Settings'
    Boolean isInActiveTrigger = false;
    if(!Test.isRunningTest()){
        isInActiveTrigger = Trigger_Settings__c.getInstance(UserInfo.getProfileId()).InactivateCreateCampaignHistoryFromLead__c;
    }

    if(isInActiveTrigger == true) {
        return;
    }
    
    List<Lead> leadstoconsider = New List<Lead>();
    Map<String,Id> occcampaignmap = new Map<String,Id>();
    Map<Id,Id> leadcampaignmap = new Map<Id,Id>();
    List<Campaignmember> campmemlist = new List<Campaignmember>();
    Set<Id> leadids = new Set<Id>();
    String OCCvalue;
    set<String> existingCampaignMembers= new set<String>();
    Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
    
    for(Lead ld : trigger.new)
    {
        system.debug('ARC debug lead record type:'+rt_map.get(ld.recordTypeID).getName());
        system.debug('ARC debug createdbyid:'+ld.createdbyid);
        system.debug('ARC debug z_source:'+ld.z_source__c);
        system.debug('ARC debug Omniture_Campaign_Code:'+ld.Omniture_Campaign_Code__c);
        if (rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('PGi') && ld.createdbyid != '0051300000C42AnAAJ' && ld.z_Source__c != 'Salesgateway' && ld.Omniture_Campaign_Code__c <> null)
        leadids.add(ld.id);
        system.debug('ARC debug leadstoconsider OCC' +leadids);
    }
    
    if(!leadids.isEmpty()){
    system.debug('ARC debug leadids not null');
    for(CampaignMember existingCampaignMember : [Select LeadId, CampaignId from CampaignMember where LeadId in :LeadIds]){
            existingCampaignMembers.add(existingCampaignMember.LeadId+'~'+existingCampaignMember.CampaignId);
    }
    system.debug('ARC debug existingcampaignmembers:'+existingCampaignMembers);
    Leadstoconsider = [Select Id,Omniture_Campaign_Code__c,Omniture_Campaign_Code_Copy__c from Lead where ID IN :Leadids];
    List<Omniture_Campaign_Code__c> occlist = [Select Id,campaign__c,omniture_campaign_code__c from Omniture_Campaign_Code__c];
    system.debug('ARC debug leadstoconsider:'+leadstoconsider);
    system.debug('ARC debug occlist:'+occlist);
        
    for (Omniture_Campaign_code__c occ : occlist)
    {
        occcampaignmap.put(occ.omniture_campaign_code__c,occ.campaign__c);
    }
    for(Lead ld : Leadstoconsider)
    {
        system.debug('ARC debug Lead OCC value :'+ld.Omniture_Campaign_Code__c);
        if(ld.Omniture_Campaign_Code__c <> null){
        system.debug('ARC debug entered for ld id:'+ld.id);
        system.debug('ARC debug lead OCC:'+ld.Omniture_Campaign_Code__c);
        if(!ld.Omniture_Campaign_Code__c.contains(':'))
        {
            system.debug('ARC debug OCC doesnot contain colon');
            OCCvalue = ld.Omniture_Campaign_Code__c;
        }
        else
        {
            system.debug('ARC debug OCC contain colon');
            List<String> OCCparts = ld.Omniture_Campaign_Code__c.split(':');
            if(OCCparts.size()>=4)
                OCCvalue = OCCparts[0] + ':' + OCCparts[1] + ':' + OCCparts[2] + ':'; 
            else
                OCCvalue = ld.Omniture_Campaign_Code__c;   
        }
        system.debug('ARC debug OCC value:'+OCCvalue);
        if(occcampaignmap.containskey(OCCvalue))
        {
            leadcampaignmap.put(ld.id,occcampaignmap.get(OCCvalue));
            system.debug('ARC debug leadcampaignmap:'+leadcampaignmap);
        }
    }        
    }
    for(Lead ld : Leadstoconsider)
    {
        if(ld.Omniture_Campaign_Code__c <> null){
        if(leadcampaignmap.containskey(ld.id))
        {
            if(leadcampaignmap.get(ld.id) <> null)
            {
                if(!existingcampaignmembers.contains(ld.id+'~'+leadcampaignmap.get(ld.id)))
                    campmemlist.add(new Campaignmember(LeadId=ld.Id,CampaignId=leadcampaignmap.get(ld.id)));
                if(ld.Omniture_Campaign_Code_Copy__c <> null)
                    ld.Omniture_Campaign_Code_Copy__c=ld.Omniture_Campaign_Code_Copy__c +';'+ ld.Omniture_Campaign_Code__c;    
                else
                    ld.Omniture_Campaign_Code_Copy__c=ld.Omniture_Campaign_Code__c;        
            }
        } 
        ld.Omniture_Campaign_Code__c = null;
        }
    } 
    system.debug('ARC debug campmemlist:'+campmemlist);       
    if(!campmemlist.isEmpty()){
    insert campmemlist;
    }
    update LeadstoConsider;
    

    }    
}