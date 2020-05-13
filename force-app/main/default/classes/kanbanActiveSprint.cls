public with sharing class kanbanActiveSprint {
    
    @AuraEnabled(cacheable=true)
    public static kanbanWrap getActiveAgiles(String objName, String[] objFields, String kanbanField, Boolean isForBackLog ,String selectedGroup,string field,Boolean order){
        
        System.debug('objName: '+objName);
        System.debug('objFields: '+objFields);
        System.debug('field: '+field);
        System.debug('order: '+order);
        System.debug('kanbanField: '+kanbanField);
        System.debug('isForBackLog: '+isForBackLog);
        System.debug('selectedGroup: '+selectedGroup);
        List<String> lstPickvals=new List<String>();
        
        // RT-559 
        String fieldtoOrder= ' '+field;
        //checking order
        if(order == true){
            fieldtoOrder += ' ASC NULLS FIRST';
        }
        else{
            fieldtoOrder += ' DESC NULLS LAST';  
        }
        //end ordering
        if(isForBackLog){
            List<String> notBacklogPickvals=new List<String>();
            List<String> backlogPickvals=new List<String>();
            for(AgileSprint__c objAS : [SELECT Id, Name 
                                        FROM AgileSprint__c 
                                        WHERE AssociatedGroup__c =:selectedGroup 
                                        AND (Status__c = 'Not Started' OR Status__c = 'Active')
                                        ORDER BY StartDate__c ASC ]){
                                            if(objAS.Name == 'Backlog'){
                                                backlogPickvals.add(objAS.Name);
                                            }
                                            else{
                                                notBacklogPickvals.add(objAS.Name);
                                            }
                      
            }
            lstPickvals.addAll(notBacklogPickvals);
            lstPickvals.addAll(backlogPickvals);
        }else{
           /* for (Schema.PicklistEntry a : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(kanbanField).getDescribe().getPickListValues()){
                lstPickvals.add(a.getValue());
            }*/
        }
        
        System.debug(lstPickvals);
        
        String query = 'SELECT Id, ';
        for(String s:objFields){
            query += s+' ,';
        }
        query = query.removeEnd(',');
       
        if(isForBackLog){
            query += ' FROM ' + objName +' WHERE AgileSprint__r.AssociatedGroup__c =\''+selectedGroup+'\' AND isClosed = false AND  (AgileSprint__r.Status__c = \'Not Started\' OR AgileSprint__r.Status__c = \'Active\') AND AgileSprint__c != null ORDER BY '+fieldtoOrder;
        }
        else{
            query += ' FROM ' + objName +' WHERE AgileSprint__r.AssociatedGroup__c =\''+selectedGroup+'\' AND isClosed = false AND AgileStatus__c != null AND AgileSprint__r.Name != \'Backlog\' AND AgileSprint__c != null AND AgileSprint__r.Status__c = \''+'Active'+'\' ORDER BY '+fieldtoOrder;   
        }
        System.debug('qq  ' + query);
        System.debug('123Records  ' + Database.query(query));
        
        return new kanbanWrap(Database.query(query), lstPickvals);
    }    

    // @AuraEnabled 
    // public static kanbanWrap getUpdatedCaseprecision(String objName, String[] objFields, String kanbanField, Boolean isForBackLog ,String selectedGroup,Boolean isloaded){       
    //     System.debug('getUpdatedCaseprecision: isloaded----'+isloaded);    
    //     System.debug('objName: '+objName);      
    //     System.debug('objName: '+objName);
    //     System.debug('objFields: '+objFields);
    //     System.debug('kanbanField: '+kanbanField);
    //     System.debug('isForBackLog: '+isForBackLog);
    //     System.debug('selectedGroup: '+selectedGroup);
    //     List<String> lstPickvals=new List<String>();
    //    System.debug('isloaded------>'+isloaded);     
    //    //if(isloaded){   
    //     if(isForBackLog){
    //         for(AgileSprint__c objAS : [SELECT Id,Name FROM AgileSprint__c WHERE AssociatedGroup__c =:selectedGroup ORDER BY StartDate__c ASC]){
    //             lstPickvals.add(objAS.Name);
    //         }
    //     }else{
    //        /* for (Schema.PicklistEntry a : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(kanbanField).getDescribe().getPickListValues()){
    //             lstPickvals.add(a.getValue());
    //         }*/
    //     }
        
    //     System.debug(lstPickvals);
        
    //     String query = 'SELECT Id, ';
    //     for(String s:objFields){
    //         query += s+' ,';
    //     }
    //     query = query.removeEnd(',');
    //         String casenullSprintQuerry = query;
    //         casenullSprintQuerry += ' FROM ' + objName +' WHERE AgileSprint__c = null ORDER BY KanbanOrder__c ASC NULLS FIRST';
    //     // query += ' FROM ' + objName +' Limit 30 ' ;
    //     // query += ' FROM ' + objName +' WHERE AgileSprint__r.Status__c = \''+'Active'+'\'';
    //     if(isForBackLog){
    //     query += ' FROM ' + objName +' WHERE AgileSprint__r.AssociatedGroup__c =\''+selectedGroup+'\' AND AgileSprint__c != null ORDER BY KanbanOrder__c ASC NULLS FIRST';
    //     }
    //     else{
    //         query += ' FROM ' + objName +' WHERE AgileSprint__r.AssociatedGroup__c =\''+selectedGroup+'\' AND AgileSprint__c != null AND AgileSprint__r.Status__c = \''+'Active'+'\' ORDER BY KanbanOrder__c ASC NULLS FIRST';   
    //     }
    //     System.debug('qq  ' + query);
    //     System.debug('line85------>' + Database.query(query));    
       
    //     List<Case> lstcases= new List<Case>();
    //     lstcases=Database.query(query);       
    //     lstcases =Database.query(casenullSprintQuerry);                 
    //     List<Case> lstupdatecase =  new List<Case>();  
    //     System.debug('lstcases----->'+lstcases.size());             
    //     Double i=0;      
    //     for(case obj:lstcases){
    //       i++;
    //       obj.Precision__c=i;
    //       lstupdatecase.add(obj);
    //     } 
       
    //    if(!lstupdatecase.isEmpty()){         
    //       update lstupdatecase;
    //      System.debug('updated lstupdatecase- size---->'+lstupdatecase.size());              
    //    } 
    //     return new kanbanWrap(Database.query(query), lstPickvals , Database.query(casenullSprintQuerry));
    // //   }  
    //   //retun null;
    // }
    
    public class kanbanWrap{
        @AuraEnabled
        public List<sObject> records {get;set;}
        @AuraEnabled
        public List<String> pickVals {get;set;}
        
        public kanbanWrap(List<sObject> recs, List<String> pVals ){
            this.records = recs;
            this.pickVals = pVals;
        }
    }

    @AuraEnabled
    public static String getUpdateStage(Id recId, String kanbanField, String kanbanNewValue, Boolean isForBackLog,String groupselected) {
        System.debug('recId: '+recId+' kanbanField: '+kanbanField+' kanbanNewValue: '+kanbanNewValue+' isForBackLog: '+isForBackLog+'groupselected'+groupselected);
        SObject o1 = recId.getSObjectType().newSObject(recId);
        if(isForBackLog && kanbanNewValue != null){
            Id agileSprintId = [SELECT Id FROM AgileSprint__c WHERE Name =: kanbanNewValue AND AssociatedGroup__c =:groupselected].Id;
            kanbanNewValue = agileSprintId;
        }
        // else if(isForBackLog && kanbanNewValue == null){
        //    Id agileSprintId = [SELECT Id FROM AgileSprint__c WHERE Name ='Backlog'].Id;
        //     kanbanNewValue = agileSprintId;
        // }
        o1.put(kanbanField,kanbanNewValue);
        System.debug('The Case'+o1);
        //have to bypass trigger.
        update o1;
        return 'Success';
    }

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

    // @AuraEnabled
    // public static List<AgileSprint__c> getallSprint(){
    //     List<AgileSprint__c> agileList = [SELECT Id, Name, AssociatedGroup__c, Status__c 
    //                                       FROM AgileSprint__c];
    //     return agileList;
    // }


    @AuraEnabled
    public static void updateStatus(String sprintName , String name ,String groupSelected){
        System.debug('The group'+groupSelected);
        System.debug('The sprintName'+sprintName);
        System.debug('The name'+name);
        AgileSprint__c agileObj = [SELECT Id, Name, AssociatedGroup__c,Status__c 
                                           FROM AgileSprint__c
                                           WHERE Name =:sprintName
                                  		   AND AssociatedGroup__c =:groupSelected];
        if(name == 'Start'){
                agileObj.Status__c ='Active';  
            } 
        else if(name == 'Complete'){
            agileObj.Status__c ='Completed';
        }  
        else{
            agileObj.Status__c ='Canceled';
        }                          
        UPDATE agileObj;
        // List<AgileSprint__c> agileLst = [SELECT Id,Name,AssociatedGroup__c,Status__c 
        //                                   FROM AgileSprint__c
        //                                   WHERE Status__c ='Active'
        //                                   AND AssociatedGroup__c =:groupName];
        // AgileSprint__c agileObj = [SELECT Id,Name,AssociatedGroup__c,Status__c 
        //                                   FROM AgileSprint__c
        //                                   WHERE Name =:sprintName];
        //                                   System.debug('The list'+agileObj);
        // if(agileLst.size() == 0 && name == 'Start'){
        //         agileObj.Status__c ='Active';  
        //         UPDATE  agileObj;
        //         return true;
        // }
        // else{
        //     if(name == 'Complete'){
        //         agileObj.Status__c ='Completed';  
        //     }
        //     if(name == 'Cancel')
        //     {
        //         agileObj.Status__c ='Canceled';  
        //     }
        //     UPDATE  agileObj;
        //     return false;  
        // }
    }
    @AuraEnabled
    public static Map<String,List<String>> getAgileStatusToGroup(){
        Map<String,List<String>> groupToStatusMap = new Map<String,List<String>>();
        for(AssGroupToAgileStatus__mdt grpToStatusMtd :[SELECT Id,GroupName__c,AgileStatus__c 
                                                        FROM AssGroupToAgileStatus__mdt]){
            String statusStr = grpToStatusMtd.AgileStatus__c;
            List<String> statusLst = statusStr.split(',');
             groupToStatusMap.put(grpToStatusMtd.GroupName__c,statusLst);
        }
        return groupToStatusMap;
    }
   //Disable the complete and cancel on load. 
    @AuraEnabled
    public static Map<String,String> getAgileNameToStatus(){
        Map<String,String> agileNameToStatus = new Map<String,String>();
        for(AgileSprint__c agileObj :[SELECT Id,Name,AssociatedGroup__c,Status__c 
                                        FROM AgileSprint__c 
                                        ]){
                                            agileNameToStatus.put(agileObj.Name,agileObj.Status__c);
                                        }
        return agileNameToStatus;
    }

    @AuraEnabled
    public static Map<String,Boolean> getGroupToStatus(){
        Map<String,List<String>> groupToLstStatus = new Map<String,List<String>>();
        List<String> groupLst = new List<String>();
        Map<String,Boolean> groupIsActiveMap = new Map<String,Boolean>();
        for(AssGroupToAgileStatus__mdt grpToStatusMtd :[SELECT Id,GroupName__c,AgileStatus__c 
                                                                FROM AssGroupToAgileStatus__mdt]){
                                                                    groupLst.add(grpToStatusMtd.GroupName__c);
                                                                }
        for(AgileSprint__c agileObj :[SELECT Id,Name,AssociatedGroup__c,Status__c 
                                        FROM AgileSprint__c
                                        WHERE  Status__c ='Active']){
                                            if(!groupToLstStatus.containskey(agileObj.AssociatedGroup__c)){
                                                groupToLstStatus.put(agileObj.AssociatedGroup__c, new List<String>{});
                                                }
                                                groupToLstStatus.get(agileObj.AssociatedGroup__c).add(agileObj.Status__c);    
                                        }
                                        System.debug('The groupToLstStatus'+groupToLstStatus);
                                        System.debug('The groupLst'+groupLst);
        for(String str :groupLst){
            if(groupToLstStatus.containsKey(str)){
            List<String> totalActive =groupToLstStatus.get(str);
            if(totalActive.size() == 0){
                groupIsActiveMap.put(str,false);
            }
            else{
                groupIsActiveMap.put(str,true);  
            }
        }
        else{
            groupIsActiveMap.put(str,false);
        }
        }
        System.debug('The Group'+groupIsActiveMap);
        return groupIsActiveMap;
    }



    @AuraEnabled
    public static void setPrecision(List<Case> caseLst , String sprintName,String caseId ,Boolean isBacklof,Integer Index){
       System.debug('The List'+caseLst.Size());
       System.debug('The sprintName'+sprintName);
       System.debug('The caseId'+caseId);
       System.debug('The Index'+Index);
       List<Case> cseLst = new List<Case>();
       Integer indexVal;
       //For backlogCasesOnly since sprintName will not be there
       if(sprintName == '' || sprintName == null){
        cseLst = caseLst;
        System.debug('The List'+cseLst);
       }
       else{
            for(case objCase :  caseLst){
                if(isBacklof){
                    if(objCase.AgileSprint__r.Name == sprintName){
                        cseLst.add(objCase);
                    }
                }
                else{
                    if(objCase.AgileStatus__c == sprintName){
                        cseLst.add(objCase);
                    }
                }
                
            }  
       }

       System.debug('for bfefore List'+cseLst.size());
        
       for(Integer i = 0 ; i < cseLst.size() ; i++){
        System.debug('The cseLst.size()'+cseLst.size());
           if(cseLst[i].Id == caseId){
               System.debug('The Index'+i);
               indexVal =i;
           }
       }

       Decimal casePrecisionVal;
       Decimal topPre;
       Decimal bottomPre;
       //if we drop below the the li(ie:After all the li in bottom empty space)
      if(Index == null){
          //If in ul only one case and Dropping it to below no need to update
            if(cseLst.size() != 1){
                System.debug('Undefined'+cseLst[cseLst.size() - 1].Precision__c);
                System.debug('CaseNumber'+cseLst[cseLst.size() - 1].CaseNumber);
                System.debug('CaseNumber'+cseLst[cseLst.size() - 1].Id);
                UPDATE new Case(Id = caseId, Precision__c = cseLst[cseLst.size() - 1].Precision__c + 1);
            }
      }
      else{
            //if list Size is one and if we are draging then no need to update.
            if(cseLst.size() != 1){ 
                System.debug('Testing For Null');
                    //if we drag card for last Index.
                    if(indexVal == cseLst.size() -1){
                        topPre = [Select Id,Precision__c From Case Where Id =:cseLst[indexVal - 1].Id].Precision__c;
                        system.debug('The pre'+topPre);
                            if(topPre == null){
                            casePrecisionVal = 0;
                            System.debug('The casePrecisionVal'+casePrecisionVal);
                            }
                            else{
                                casePrecisionVal = topPre + 1; 
                                System.debug('The casePrecisionVal'+casePrecisionVal);
                            }
                    }
                    else if(indexVal != 0){
                        topPre = [Select Id,Precision__c From Case Where Id =:cseLst[indexVal - 1].Id].Precision__c;
                        
                        bottomPre = [Select Id,Precision__c From Case Where Id =:cseLst[indexVal + 1].Id].Precision__c;
                        
                        if( (topPre == null && bottomPre == null) || (topPre == null && bottomPre != null)){
                            casePrecisionVal = 0;
                        }else if(topPre != null && bottomPre != null){
                            casePrecisionVal = getInbetweenNumer(topPre,bottomPre);
                        }

                        System.debug('casePrecisionVal: '+casePrecisionVal);
                        System.debug('The Top: '+topPre);
                        System.debug('The bottomPre: '+bottomPre);
                }
                    else{
                        System.debug('The bottomPre: '+bottomPre);
                            casePrecisionVal = 0;
                    }
                    //Have to bypass Trigger
                    UPDATE new Case(Id = caseId, Precision__c = casePrecisionVal);
            }
        }
    }

    public static decimal getInbetweenNumer(Decimal prevNum, Decimal nextNumber){
        Decimal diffInRange = nextNumber-prevNum;
        System.debug('Top+ '+prevNum);
        System.debug('bottom+ '+nextNumber);
        System.debug('diffInRange: '+diffInRange);

        Decimal randomNum = Math.random()*diffInRange+prevNum;
        System.debug('randomNum: '+randomNum);

        return randomNum;
    }

}