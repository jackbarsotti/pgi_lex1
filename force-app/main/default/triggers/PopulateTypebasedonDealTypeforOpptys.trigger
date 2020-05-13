trigger PopulateTypebasedonDealTypeforOpptys on Opportunity (before insert,before update) {

Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();

for ( Opportunity opp : trigger.new)
{
    if((Trigger.isInsert && rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('PGi') && opp.Opportunity_Deal_Type__c <> null) || (Trigger.isUpdate && rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('PGi') && opp.Opportunity_Deal_Type__c <> null && opp.Opportunity_Deal_Type__c != Trigger.oldMap.get(opp.Id).Opportunity_Deal_Type__c))
    {
        if(opp.opportunity_deal_type__c == 'Up-Sell (Rev Increase)' || opp.opportunity_deal_type__c == 'Down-Sell (Rev Decrease)' || opp.opportunity_deal_type__c == 'Renewal (No Rev Change)')
            opp.type = 'Existing Cust- Existing Svc';
        if(opp.opportunity_deal_type__c == 'Conversion')
            opp.type = 'Existing Cust- New Svc';
        if(opp.opportunity_deal_type__c == 'New Logo' || opp.opportunity_deal_type__c == 'Cross-Sell')
            opp.type = 'New Business';
        if(opp.opportunity_deal_type__c == 'Win Back')
            opp.type = 'Winback'; 
     }                     
}
}