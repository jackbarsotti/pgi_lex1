public with sharing class AgileKanbanController {
    public static final String LEAD_MOVED = '{0} was moved successfully to {1} and column ordering was updated.';
    
    //////////////////
    //Aura Handlers //
    //////////////////

    @AuraEnabled
    public static DataFetchResult initialize() {
        DataFetchResult result = new DataFetchResult();

        getAgileSprintNames( result );
        fetchCases( result );

        return result;
    }
    
    @AuraEnabled
    public static StatusUpdateResult updateCaseKanbanOrder( Id caseId, String newLeadStatus, List<String> ordering ) {
        try {
            Case objCase = [
                SELECT  Id
                        ,CaseNumber
                        ,AgileStatus__c
                FROM    Case
                WHERE   Id = :caseId
            ];
        
            objCase.AgileStatus__c = newLeadStatus;
            UPDATE objCase;
            
            /**
             * Update all the Case records
             * with the new ordering.
             */
            List<Case> leadsToUpdate = new List<Case>();
            Integer counter = 1;
            for( String recId : ordering ) {
                leadsToUpdate.add( new Case( Id = recId, Kanban_Sort_Order__c = counter++ ) );
            }
            
            UPDATE leadsToUpdate;
        
            return new StatusUpdateResult(
                TRUE,
                'Success',
                String.format( LEAD_MOVED, new List<String>{ objCase.CaseNumber, newLeadStatus } )
            );
        }
        catch( Exception ex ) {        
            return new StatusUpdateResult(
                FALSE,
                'Error',
                ex.getMessage()
            );
        }
    }        
    
    ///////////////////
    //Public Classes //
    ///////////////////
    
    public class Column {
        @AuraEnabled
        public String label 					{ get; set; }
        
        @AuraEnabled
        public Boolean isDropEnabled 			{ get; set; }
        
        public Column( String label, Boolean isDropEnabled ) {
            this.label = label;
            this.isDropEnabled = isDropEnabled;
        }
    }
    
    public class DataFetchResult {
        @AuraEnabled
        public List<Column> columns        		{ get; set; }

        @AuraEnabled
        public Map<String, List<Case>> rows    	{ get; set; }
    }

    public class StatusUpdateResult {
        @AuraEnabled
        public Boolean isSuccess				{ get; set; }

        @AuraEnabled
        public String title						{ get; set; }
        
        @AuraEnabled
        public String message					{ get; set; }

        public StatusUpdateResult( Boolean isSuccess, String title, String message ) {
            this.isSuccess  = isSuccess;
            this.title      = title;
            this.message    = message;
        }
    }

    ///////////////////////////
    //Private Helper Methods //
    ///////////////////////////
    
    static void getAgileSprintNames( DataFetchResult result ) {
        result.columns = new List<Column>();
        
        AgileKanbanSettings__c settings = AgileKanbanSettings__c.getInstance( UserInfo.getOrganizationId() );
        
        Set<String> dropProhibtedCols = new Set<String>();
        if( settings.Drop_Prohibited_Columns__c != NULL ) {            
            dropProhibtedCols.addAll( settings.Drop_Prohibited_Columns__c.split( ',' ) );
        }
        
        for( String agileStatus : getPickListValuesIntoList('Case','AgileStatus__c')) {
            result.columns.add(
                new Column(
                    agileStatus.trim(),
                    !dropProhibtedCols.contains( agileStatus )
                )
			);
        }
    }
    
    static void fetchCases( DataFetchResult result ) {
        List<Case> caseList = [
            SELECT  Id, Precision__c, CaseNumber, GeneralDetails__c
                    ,AgileStatus__c, AgileSprint__c
                    ,Assigned_To__c, Assigned_To__r.Name
                    ,AgileTester__c, AgileTester__r.Name
                    ,AgileEpic__c, AgileEpic__r.Name
                    ,AgileEpic__r.EpicColor__c, AgileSprint__r.Name
            		,Kanban_Sort_Order__c, AgileSprint__r.AssociatedGroup__c, AgileSprint__r.Status__c
            FROM    Case WHERE AgileSprint__r.Status__c = 'Active' AND AgileSprint__c != null
            ORDER BY Kanban_Sort_Order__c ASC 
        ];
        
        result.rows = new Map<String, List<Case>>();
        
        for( Column col : result.columns ) {
            result.rows.put( (col.label).trim(), new List<Case>{} );
        }
        
        for( Case objCase : caseList ) {
            if( result.rows.containsKey( objCase.AgileStatus__c ) ) {
                result.rows.get( objCase.AgileStatus__c ).add( objCase );
            }
        }
    }

    /**
     * method: getAgileStatusbyAssociatedGroup
     * params:  
     * Descrition: To get AgileStatus values by Selceted Associated Group based on Meta data values
     * return type: Map<String,List<String>> 
     * */ 
    @AuraEnabled
    public static Map<String,List<String>> getAgileStatusbyAssociatedGroup(){
        Map<String,List<String>> groupToStatusMap = new Map<String,List<String>>();
        for(AssGroupToAgileStatus__mdt grpToStatusMtd :[SELECT Id,GroupName__c,AgileStatus__c 
                                                        FROM AssGroupToAgileStatus__mdt]){
            String statusStr = grpToStatusMtd.AgileStatus__c;
            List<String> statusLst = statusStr.split(',');
             groupToStatusMap.put(grpToStatusMtd.GroupName__c,statusLst);
        }
        return groupToStatusMap;
    }


    /**
     * method: getPickListValuesIntoList
     * params: ObjectApi_name, Field_name
     * Descrition: To get picklist values by Object Field
     * return type: List<String> 
     * */ 
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        // lstPickvals.add('All');
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        System.debug('The Case'+lstPickvals);
        return lstPickvals;
    }
}