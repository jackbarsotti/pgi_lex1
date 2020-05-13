public class PickListDescController {
    public Sobject sobj {get;set;}
    public String pickListFieldName {get;set;}        
    
    public PickListDescController() {
    //    Map<String, String> reqParams = ApexPages.currentPage().getParameters();
    //    String sobjId = reqParams.get('id');
    //    String recordTypeId = reqParams.get('recordTypeId');
    //    String recordTypeName = reqParams.get('recordTypeName');
    //    String sobjectTypeName = reqParams.get('sobjectType'); 
    //    this.pickListFieldName = reqParams.get('picklistFieldName'); 
        
    //    Schema.SobjectType sobjectType = null;
    //    system.debug('sobjectTypeName==='+sobjectTypeName);
    //    system.debug('recordTypeId==='+recordTypeId);
    //    system.debug('pickListFieldName==='+pickListFieldName);
        
    //    if (sobjectTypeName != null && sobjectTypeName.trim().length() > 0) {
    //        sobjectType = Schema.getGlobalDescribe().get(sobjectTypeName);
    //        // create blank sobject record
    //        sobj = sobjectType.newSobject();
    //        if(recordTypeid != null){
    //        	sobj.put('RecordTypeId', recordTypeid);
    //        }
    //    }  
    }

    public void getPicklistValuesforRT(){
        Map<String, String> reqParams = ApexPages.currentPage().getParameters();
        String recordTypeId = reqParams.get('recordTypeId');
        String sobjectTypeName = reqParams.get('sobjectType'); 
        this.pickListFieldName = reqParams.get('picklistFieldName'); 
        
        Schema.SobjectType sobjectType = null;
        system.debug('sobjectTypeName=11=='+sobjectTypeName);
        system.debug('recordTypeId=11=='+recordTypeId);
        system.debug('pickListFieldName=11=='+pickListFieldName);
        
        if (sobjectTypeName != null && sobjectTypeName.trim().length() > 0) {
            sobjectType = Schema.getGlobalDescribe().get(sobjectTypeName);
            // create blank sobject record
            sobj = sobjectType.newSobject();
            if(recordTypeid != null){
                sobj.put('RecordTypeId', recordTypeid);
            }
        }  
    }
}