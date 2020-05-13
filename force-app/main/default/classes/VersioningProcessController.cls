public with sharing class VersioningProcessController {
    
    public Attachment attachementVersionFrom {get; set;}
    public Attachment attachementVersionTo {get; set;}
    public Id versionHistoryId {get; set;}
    public Id ParentId {get; set;}
    public String Fromversion {get; set;}
    public String ToVersion {get; set;}
    public String output {get; set;}
    public String sObjectName{get; set;}
    public String fromType {get; set;}
    public String toType {get; set;}
    public String fromBody {get; set;}
    public String toBody {get; set;}
    public Sobject sObj{get; set;}
    public Map<String,Object> fromBodyMap {get; set;}
    public Map<String,Object> toBodyMap {get; set;}
    public String objectRecName {get; set;}
    public Boolean returnSobject {get; set;}
    
    public Map<Id,Attachment> attachmentById {get; set;}
    
    public VersioningProcessController(ApexPages.StandardController controller) {

        versionHistoryId =ApexPages.currentPage().getParameters().get('id');
        // ParentId=ApexPages.currentPage().getParameters().get('ParentId');
        // system.debug('===>'+versionHistoryId);
        returnSobject = false;
        attachementVersionFrom =[SELECT Id, ParentId, Name, BodyLength, ContentType, Body, CreatedBy.Name ,createdDate
                                        FROM Attachment
                                        WHERE ParentId=:versionHistoryId 
                                        ORDER BY createdDate ASC LIMIT 1 ];
        attachementVersionTo = attachementVersionFrom;
        fromType = attachementVersionFrom.name;
        toType = fromType;
        fromBody = (attachementVersionFrom.Body).toString();
        Map<String,Object> fromBodyMap = (Map<String,Object>)JSON.deserializeUntyped(fromBody);
        fromBody = '';
        for(String str: fromBodyMap.keySet()){
            if(str == 'attributes'){
                String[] type = String.valueOf(fromBodyMap.get('attributes')).split(',');
                String[] apiName = type[0].split('=');
                sObjectName = apiName[1];
            }
            fromBody =fromBody+ str+ ' : ' + fromBodyMap.get(str) +'<br/>';
        }
        String sql = 'SELECT Id, Name FROM '+ sObjectName + ' WHERE Version_History__c =: versionHistoryId LIMIT 1';
        sObj = Database.query(sql);
        objectRecName = String.valueOf(sObj.get('Name'));
        toBody = fromBody;
        // Fromversion = 'Current Version';
        // ToVersion = 'Current Version';
    }
    
    public List<SelectOption> versionOption {get {
        if(versionOption == null) {
            versionOption = new List<SelectOption>();
            attachmentById = new Map<Id,Attachment>();
            List<SelectOption> toSort = new List<SelectOption>();
            for(Attachment ObjVersion : [SELECT Id, ParentId, Name, BodyLength, ContentType, Body, CreatedBy.Name 
                                                                    FROM Attachment
                                                                    WHERE ParentId=:versionHistoryId]) {                                              
                                                                     attachmentById.put(ObjVersion.Id , ObjVersion);
                                                                     toSort.add(new SelectOption(ObjVersion.Name, ObjVersion.Id)); 
                                                                     
                                                                 }
            toSort.sort();
            for(SelectOption so: toSort) {
                versionOption.add(new SelectOption(so.getLabel(), so.getValue()));
            }
        }
        
        return versionOption;
    } set;}
    
    public void getValuestocompare(){
       if(Fromversion != ToVersion){
            returnSobject = true;
       }
       if(Fromversion == null) {
           Fromversion = ToVersion;
       }
        attachementVersionFrom =[SELECT Id, ParentId, Name, BodyLength, ContentType, Body, CreatedBy.Name
                                        FROM Attachment
                                        WHERE Id=:Fromversion limit 1];
    
        fromType = attachementVersionFrom.Name;
        fromBody = (attachementVersionFrom.Body).toString();
        // fromBody = fromBody.replace(',',' ');
        Map<String,Object> fromBodyMap = (Map<String,Object>)JSON.deserializeUntyped(fromBody);
        fromBody = '';
        for(String str: fromBodyMap.keySet()){
            fromBody =fromBody+ str+ ' : ' + fromBodyMap.get(str) +'<br/>';
        }
      
        
        // fromBody = String.valueOf(fromBodyMap);

        
        attachementVersionTo =[SELECT Id, ParentId, Name, BodyLength, ContentType, Body, CreatedBy.Name
                                FROM Attachment
                                WHERE Id=:ToVersion limit 1];   
        toType = attachementVersionTo.Name;
        toBody = (attachementVersionTo.Body).toString();
        // toBody = toBody.replace(',',' ');
        Map<String,Object> toBodyMap = (Map<String,Object>)JSON.deserializeUntyped(toBody);
        toBody = '';
        for(String str: toBodyMap.keySet()){
            toBody =toBody+ str+ ' : ' + toBodyMap.get(str) +'<br/>';
        }
        
        
        //return null;
    }
    // public void saveVersionHistory(){
    //     String objectAPIName = ParentId.getSObjectType().getDescribe().getName();
    //     String soqlQuery = 'SELECT Version_History__c FROM '+objectAPIName+' WHERE id=: ParentId';

    //     SObject obj = Database.query(soqlQuery);
    //     if(obj.get('Version_History__c') == null){
    //         Version_History__c verHistoryObj = new Version_History__c();
    //         verHistoryObj.Name = fromType +'-'+toType;
    //         INSERT verHistoryObj;
    //         if( objectAPIName == 'Contract_Terms__c'){
    //             Contract_Terms__c conTermsObj = (Contract_Terms__c)obj;
    //             conTermsObj.Version_History__c = verHistoryObj.id;
    //             UPDATE conTermsObj;
    //         }else if(objectAPIName == 'PGIServicesInformation__c'){
    //             PGIServicesInformation__c pgiServiceInfoObj = (PGIServicesInformation__c)obj;
    //             pgiServiceInfoObj.Version_History__c = verHistoryObj.Id;
    //             UPDATE pgiServiceInfoObj;
    //         }
    //         createAttachment(verHistoryObj.id);
    //     }else{
    //         createAttachment((Id)obj.get('Version_History__c'));
    //     }
    // }
    public void createAttachment(Id parentRecId){
        if(parentRecId != null){
            system.debug('output-->'+output);
            Attachment attach=new Attachment();  
                attach.Name=fromType+'-'+toType;  
                Blob bodyBlob=Blob.valueOf(JSON.serialize(output));
                attach.body=bodyBlob;
                attach.parentId = parentRecId;
            INSERT attach;
        }
    }
    public PageReference  returnToSobject(){
    //    system.debug('url=>'+URL.getOrgDomainUrl().toExternalForm());
        PageReference pg = new PageReference('/'+sObj.Id);
        pg.setRedirect(true);
        return pg;
    }

}