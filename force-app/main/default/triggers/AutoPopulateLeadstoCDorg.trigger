trigger AutoPopulateLeadstoCDorg on Lead (after insert) {
    // try {
    //     PartnerNetworkConnection conn = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection  where ConnectionStatus = 'Accepted' and ConnectionName = 'Central Desktop, Inc.'];
    //     List<PartnerNetworkRecordConnection> recordConnectionToInsert  = new List<PartnerNetworkRecordConnection>  ();
    //     //User usr = [Select id,name from User where name = 'Wesley Lucas' LIMIT 1];
    //     Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
    //     for (Lead ld : Trigger.new){
    //         system.debug('ARC debug createdby name:'+ld.createdby.name);
    //         //if((rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('PGi')) && ld.createdby.name == 'Wesley Lucas')
    //         if((rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('PGi')) && ld.createdbyid == '0051300000CXIdF')
    //         //if(rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('PGi'))
    //         //system.debug('ARC debug of Lead RecordtypeID:' +ld.recordtypeid);
    //         {
    //             PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
    //             newrecord.ConnectionId = conn.Id;
    //             newrecord.LocalRecordId = ld.id;  
    //             newrecord.SendClosedTasks = false;
    //             newrecord.SendOpenTasks = false;
    //             newrecord.SendEmails = false;
    //             recordConnectionToInsert.add(newrecord);
    //         }
    //     }
    //     if (recordConnectionToInsert.size() > 0){
    //         System.debug('>>> Sharing ' + recordConnectionToInsert.size() + ' records');
    //         insert recordConnectionToInsert;
    //     }
    // } catch (exception e){
        
    // }
}