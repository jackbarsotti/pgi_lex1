public class PIDRTriggerHandler extends TriggerHandler {
    public PIDRTriggerHandler() {
        super('PIDRTriggerHandler');
    }
    public static Boolean isExecute = True;
    protected override void afterInsert(){
        if(isExecute){
            isExecute = False;
            pidrRelatedRecordCreation((Map<Id,PIDR__c>) trigger.newMap);
        }
    }
    protected override void afterUpdate(){
        /* if(Test.isRunningTest()){
                isExecute = true;
            }*/
        if(isExecute){
            isExecute =False;
            pidrUpdatedRelatedRecordCreation((Map<Id,PIDR__c>) trigger.newMap);
        }
    }
    
    public static Id recordTypePIDRCustomer = Schema.SObjectType.PIDR__c.getRecordTypeInfosByDeveloperName().get('Customer_Request_Record_Type').getRecordTypeId(); // sObjectType = PIDR__c.
    public static Id recordTypePIDREmployee = Schema.SObjectType.PIDR__c.getRecordTypeInfosByDeveloperName().get('Employee_Request_Record_Type').getRecordTypeId(); // sObjectType = PIDR__c.
    public static Id recordTypePDIRCasePersonelInformation = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Personal_Information_Data_Request').getRecordTypeId(); 
    public static BusinessHours businessHours = [SELECT Id
                                                 From BusinessHours
                                                 Where Name='Default'];
    
    public static Map<String,Id> nameToGroupforCustomersMap{get{
        nameToGroupforCustomersMap = new Map<String,Id>();
        List<String> customersgroupNameList = new List<String> {'PGi-Case-GL-Tier 3-Zendesk','PGi-Case-GL-InfoSec','PGi-Case-GL-Tier 3-Systems Admin','PGi-Case-GL-Tier 3-Voice Delivery',
           
            'PGi-Case-BillingPlatform Support','ReadyTalk-Developement','Salesforce Support','PGi-Case-GL-Marketing Operations','TalkPoint - Case Queue'};
                
                for(Group grp : [SELECT Id,Name FROM GROUP WHERE type='Queue' and Name IN :customersgroupNameList]){
                    nameToGroupforCustomersMap.put(grp.Name, grp.Id);
                }  return nameToGroupforCustomersMap;
    } set;}
    public static Map<String,Id> nameToGroupforEmployeesMap{get{
        nameToGroupforEmployeesMap = new Map<String,Id>();
        List<String> employeegroupNameList = new List<String>{'Sales Operations Support','PGi-Case-GL-Tier 3-Zendesk','PGi-Case-GL-Tier 3-Integrations','PGi-Case-GL-InfoSec','PGi-Case-GL-PeopleSoft Support','PGi-Case-GL-Tier 3-Citrix','PGi-Case-GL-Tier 3-Saas Ops',
            'PGi-Case-GL-Tier 3-Systems Admin','PGi-Case-GL-Tier 3-Voice Delivery',
            'PGi-Case-NA-EWFM','PGi-Case-NA-TalkPoint Deskside Support','PGi-Case-PGiTime Support',
            'PGi-Case-BillingPlatform Support','PGi-Case-GL-Tier 3-Network','Salesforce Support','PGi-Case-GL-Marketing Operations','TalkPoint - Case Queue'};
                
                for(Group grp : [SELECT Id,Name FROM GROUP WHERE type='Queue' and Name IN :employeegroupNameList]){
                    nameToGroupforEmployeesMap.put(grp.Name, grp.Id);
                }return nameToGroupforEmployeesMap;
    } set;}
    public static Map<String,Id> nameToGroupforCaseOwnerIdMap{get{
        nameToGroupforCaseOwnerIdMap = new Map<String,Id>();
        List<String> caseOwnerNameList = new List<String>{'PGi-Case-EU-Branding&Conf Email','PGi-Case-AP-Facilities','PGi-Case-NA-Facilities',
            'PGi-Case-EU-Facilities','PGi-Case-EU-Employee Serv','PGi-Case-GL-Business Intelligence (BI)'};
                
                for(Group grp : [SELECT Id,Name FROM GROUP WHERE type='Queue' and Name IN :caseOwnerNameList]){
                    nameToGroupforCaseOwnerIdMap.put(grp.Name, grp.Id);
                }return nameToGroupforCaseOwnerIdMap;
    } set;}
    





    public static Case objCase = new Case(BusinessHoursId = businessHours.Id, Description ='A Personal Information Data Request has been requested. Please take action on this case immediately.',
                                          Origin = 'PIDR',Priority ='High',RecordTypeId = recordTypePDIRCasePersonelInformation, Status ='New');
    public static List<Case> caseListtoInsert = new List<Case>();
    
    private void pidrRelatedRecordCreation(Map<Id,PIDR__c> newPIDRList){
        
        for(PIDR__c obj : newPIDRList.values()){
            System.debug('STATUS'+obj.Status__c);
            if(obj.Status__c =='Approved') {
                
                String developerNamePIDR = Schema.SObjectType.PIDR__c.getRecordTypeInfosById().get(obj.RecordTypeId).getName();
                objCase.Personal_Information_Data_Request__c = obj.Id;
                objCase.Subject ='PIDR-'+developerNamePIDR+'-Action Needed Immediately';
                
                if(obj.RecordTypeId == recordTypePIDRCustomer  &&  obj.Customer_Region__c =='AP'){
                    System.debug('Email Alerts');
                }
                
                else if(obj.RecordTypeId == recordTypePIDRCustomer  &&  obj.Customer_Region__c =='EMEA'){
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Branding&Conf Email');
                    //objCase.OwnerId='00G1B000003S0yaUAC';
                    //System.debug('The GROUPIS'+nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Branding&Conf Email'));
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                }
                
                else if(obj.RecordTypeId == recordTypePIDREmployee  &&  obj.Customer_Region__c =='APAC'){
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-AP-Facilities');
                    //objCase.OwnerId='00G1B000003RzzmUAC';
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                }
                
                else if(obj.RecordTypeId == recordTypePIDREmployee  &&  obj.Customer_Region__c =='EMEA'){
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Employee Serv');
                    //objCase.OwnerId='00G1B000003RzzrUAC';
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Facilities');
                    //objCase.OwnerId='00G1B000003RzzsUAC';
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                }
                else if(obj.RecordTypeId == recordTypePIDREmployee  &&  obj.Customer_Region__c =='NA'){
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-NA-Facilities');
                    //objCase.OwnerId='00G1B000003S00fUAC';
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                }
                else if(obj.RecordTypeId == recordTypePIDREmployee){
                    objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-GL-Business Intelligence (BI)');
                    //objCase.OwnerId='00G13000004KFIuEAO';
                    caseListtoInsert.add(objCase.clone(false, false, false, false));
                }
                if(obj.RecordTypeId == recordTypePIDRCustomer){
                    for(Id ownId :nameToGroupforCustomersMap.values()){
                        objCase.OwnerId=ownId;
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                } else if(obj.RecordTypeId == recordTypePIDREmployee){
                    for(Id ownId :nameToGroupforEmployeesMap.values() ){
                        objCase.OwnerId=ownId;
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                }
            }
        }
        TriggerHandler.bypass('PIDRTriggerHandler');
        if(!caseListtoInsert.isEmpty()){
            INSERT caseListtoInsert;
        }
        TriggerHandler.clearBypass('PIDRTriggerHandler');       
    }
    
    private void pidrUpdatedRelatedRecordCreation(Map<Id,PIDR__c> newPIDRList){
        System.debug('123');
        
        Map<Id,List<Case>> pidrbyCaseMap = new Map<Id,List<Case>>();
        
        for(Case objCase : [SELECT Id,Personal_Information_Data_Request__c FROM Case WHERE Personal_Information_Data_Request__c IN : newPIDRList.keySet()]){
            if(!pidrbyCaseMap.containskey(objCase.Personal_Information_Data_Request__c)){
                 pidrbyCaseMap.put(objCase.Personal_Information_Data_Request__c, new List<Case>{});
            }
            pidrbyCaseMap.get(objCase.Personal_Information_Data_Request__c).add(objCase);
            System.debug('The value of the l;ist'+pidrbyCaseMap);
        }

        for(PIDR__c objPIDR : newPIDRList.values()){
            System.debug('objPIDR>>>First_Name__c>>>> '+objPIDR.First_Name__c+' last aneme>>>> '+objPIDR.Last_Name__c);
            System.debug('isChanged>>>>>>> '+isChanged('Status__c',objPIDR) );
            if(!pidrbyCaseMap.containskey(objPIDR.Id)){
                    if(isChanged('Status__c',objPIDR) && objPIDR.Status__c =='Approved') {
                    String developerNamePIDR = Schema.SObjectType.PIDR__c.getRecordTypeInfosById().get(objPIDR.RecordTypeId).getName();
                    objCase.Personal_Information_Data_Request__c =objPIDR.Id;
                    objCase.Subject ='PIDR-'+developerNamePIDR+'-Action Needed Immediately';
                    
                    if(objPIDR.RecordTypeId == recordTypePIDRCustomer  &&  objPIDR.Customer_Region__c =='AP'){
                        System.debug('Email Alerts');
                    }
                    else if(objPIDR.RecordTypeId == recordTypePIDRCustomer  && objPIDR.Customer_Region__c =='EMEA'){
                        //objCase.OwnerId='00G1B000003S0yaUAC';
                        objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Branding&Conf Email');
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                    else if(objPIDR.RecordTypeId == recordTypePIDREmployee  && objPIDR.Customer_Region__c =='APAC'){
                        //objCase.OwnerId='00G1B000003RzzmUAC';
                        objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-AP-Facilities');
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                    else if(objPIDR.RecordTypeId == recordTypePIDREmployee  && objPIDR.Customer_Region__c =='EMEA'){
                        //objCase.OwnerId='00G1B000003RzzrUAC';
                        objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Employee Serv');
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                        //objCase.OwnerId='00G1B000003RzzsUAC';
                        objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-EU-Facilities');
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                    else if(objPIDR.RecordTypeId == recordTypePIDREmployee  && objPIDR.Customer_Region__c =='NA'){
                        //objCase.OwnerId='00G1B000003S00fUAC';
                        objCase.OwnerId = nameToGroupforCaseOwnerIdMap.get('PGi-Case-NA-Facilities');
                        caseListtoInsert.add(objCase.clone(false, false, false, false));
                    }
                    
                    if(objPIDR.RecordTypeId == recordTypePIDRCustomer){
                        for(Id ownId :nameToGroupforCustomersMap.values() ){
                            objCase.OwnerId=ownId;
                            caseListtoInsert.add(objCase.clone(false, false, false, false));
                            system.debug('====case==customer===>'+caseListtoInsert);
                        }
                    } else if(objPIDR.RecordTypeId == recordTypePIDREmployee){
                        for(Id ownId :nameToGroupforEmployeesMap.values() ){
                            objCase.OwnerId=ownId;
                            caseListtoInsert.add(objCase.clone(false, false, false, false));
                            system.debug('====case==employee===>'+caseListtoInsert);
                        }
                    }
                }   
            }
            
        }
        TriggerHandler.bypass('PIDRTriggerHandler');
        if(!caseListtoInsert.isEmpty()){
        	INSERT caseListtoInsert;
        }
        TriggerHandler.clearBypass('PIDRTriggerHandler');
        //system.debug('=========>'+caseListtoInsert); 
    }
}