public with sharing class OppCreationWithInfoExt {
    private ApexPages.StandardController controller = null;
    public OppCreationWithInfoExt(ApexPages.StandardController controller) {
    this.controller = controller;
    }

    public PageReference SetFields(){
    Map<ID,Schema.RecordTypeInfo> rt_Map_Opp = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
    Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Opportunity; 
    List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
    String newUrl = '/'+Opportunity.SObjectType.getDescribe().getKeyPrefix()+'/e?'+ getParameters();
    if(ApexPages.currentPage().getParameters().get('RecordType') <> NULL)
    {
        if(rt_Map_Opp.get(ApexPages.currentPage().getParameters().get('RecordType')).getName().containsIgnoreCase('PGi'))
            newUrl += '&opp11=Awareness'; //Set StageName
    }
    else
    {
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.isDefaultRecordTypeMapping() && rtInfo.getName().Contains('PGi'))                
                newUrl += '&opp11=Awareness'; //Set StageName        
        }    
    }                
    return new PageReference(newUrl);
    }
  
    private String getParameters(){
    string param = '';
    Map<String, String> strMap = ApexPages.currentPage().getParameters();
    Set<String> excludeKeys = new Set<String>{'save_new', 'sfdc.override'};
    for(String key : strMap.keySet()){
        if(!excludeKeys.contains(key))
        param += key + '=' +  strMap.get(key) + '&';
    }       
    param += 'nooverride=1';
    return param;
    }
}