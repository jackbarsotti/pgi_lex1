trigger CheckPrimaryContactRole on Opportunity (before insert, before update)
{
    if(OpportunityTriggerHandler.bypassContactRole != true) {
        OpportunityTriggerHandler.bypassContactRole = true;
    Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
    Boolean isPrimary;
    Set<Id> OppIds = new Set<Id>();
    Set<Id> OppIdswithaccount = new Set<Id>();

    for ( Opportunity opp : trigger.new)
    {
        if ((rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('PGi') || rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Talkpoint')))
            oppIds.add(opp.id);
        if ((rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('PGi') || rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Talkpoint')) && opp.account_type__c == 'End User - Agent')
            oppIdswithaccount.add(opp.id);    
    }

    if(!oppIds.isEmpty()){

    List<OpportunityContactRole> oppconrolelist = [SELECT opportunityid,contactid,contact.last_survey_date__c,contact.HasOptedOutOfEmail,contact.email FROM opportunitycontactrole where isPrimary = True AND role <> 'Partner Rep' AND opportunityid IN :oppids];
    Map<Id,Contact> oppconmap = new Map<Id,Contact>();

    for ( OpportunityContactRole ocr : oppconrolelist)
    {
        oppconmap.put(ocr.opportunityid,ocr.contact); 
    }

    List<OpportunityContactRole> oppconrolelistaccount = [SELECT opportunityid,contactid,contact.last_survey_date__c,contact.HasOptedOutOfEmail,contact.email FROM opportunitycontactrole where isPrimary = False AND role = 'Decision Maker' AND opportunityid IN :oppidswithaccount];
    Map<Id,Contact> oppconmapaccnt = new Map<Id,Contact>();

    for ( OpportunityContactRole ocr : oppconrolelistaccount)
    {
        oppconmapaccnt.put(ocr.opportunityid,ocr.contact); 
    }
    for (Opportunity oppty : trigger.new)
    {
        if(!rt_map.get(oppty.recordTypeID).getName().containsIgnoreCase('PGi') && !rt_map.get(oppty.recordTypeID).getName().containsIgnoreCase('Talkpoint')) {
            continue;
        }
        if(oppconmap.containskey(oppty.id))
        {
            oppty.Primary_Contact_Assigned__c = True;
            oppty.Primary_Contact__c = oppconmap.get(oppty.id).id;
            oppty.Primary_Contact_ID__c = oppconmap.get(oppty.id).id;
            oppty.Primary_Contact_Email_Opt_Out__c = oppconmap.get(oppty.id).HasOptedOutOfEmail;
            oppty.Primary_Contact_Email_Address__c = oppconmap.get(oppty.id).email;
        } 
        else if(oppconmapaccnt.containskey(oppty.id))
        {
            oppty.Primary_Contact_Assigned__c = True;
            oppty.Primary_Contact__c = oppconmapaccnt.get(oppty.id).id;
            oppty.Primary_Contact_ID__c = oppconmapaccnt.get(oppty.id).id;
            oppty.Primary_Contact_Email_Opt_Out__c = oppconmapaccnt.get(oppty.id).HasOptedOutOfEmail;
            oppty.Primary_Contact_Email_Address__c = oppconmapaccnt.get(oppty.id).email;
        } 
        else
        {
            oppty.Primary_Contact_Assigned__c = False;
            oppty.Primary_Contact__c = null;
            oppty.Primary_Contact_ID__c = null;
            oppty.Primary_Contact_Email_Opt_Out__c = False;
            oppty.Primary_Contact_Email_Address__c = null;
        }    
    }
    }
    }
}