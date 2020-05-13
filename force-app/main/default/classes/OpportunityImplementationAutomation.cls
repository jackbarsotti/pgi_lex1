public with sharing class OpportunityImplementationAutomation {
    
    //public String OpportunityName { get; set; }
    //public String OpportunityID { get; set; }
    public list<Opportunity> SearchedOpportunities {get; set;}
    public List<oOpportunity> OpportunityList {get; set;}
    public Integer NumberofClosedOpportunities {get; set;}

   // public List<Implementation_Services__c> ImplementationInsertList {get;set;}
    public boolean Flag=false;
    public String OpportunityRefID;
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    private List<Opportunity> SortListOpportunity;
    private String currentUserRegion;
    private String currentUserChannel;
    private String oppChannelCanada = '%' + PGIAppConstants.USER_CHANNEL_CANADA;
    
    public static String strQueryFields='Select ' /*Count_of_Quote__c,'*/+
                                                  'owner.name,account.type,account.name,'+
                                                  'type,forecast_status__c,Total_GM_IM_Licenses__c,Opportunity_Number__c,'+
                                                  'id,Implementation_Review_Request__c,'+
                                                  'Name,AccountId,OwnerId,Owner_Region__c,'+
                                                  'Channel__c,StageName,CloseDate,Amount__c,'+
                                                  'Total_Annual_Value__c,isClosed ' + //,MRR_Total__c '+
                                                  'from Opportunity '+
                                                  'where ';

    public static String strQueryFilters = ' and NoISTNeeded__c = false and recordtype.name like \'%PGi%\' AND Owner.Name <> \'eCommerce Customer\' '
                                                    + 'AND stagename <> \'Closed Lost\' AND '+ 
                                                    +' CountofISTRecords__c=0 AND ' +
                                                  '(((stagename = \'Purchase\' OR Forecast_Status__c = \'Commit\') AND closedate >= 2018-12-31) OR '+
                                                  '(closedate >= 2018-12-31 AND stagename in (\'Closed Won\',\'Closed Won - Implementation\',\'Closed Won - Implementation Complete\'))) ';
    // **** Constructor******
    
    public OpportunityImplementationAutomation() {
        User currentUser = [Select Id, User_Region__c, Channel__c From User Where Id=:Userinfo.getUserId()];
        currentUserRegion = currentUser.User_Region__c;
        currentUserChannel = currentUser.Channel__c;
        if (currentUserRegion == 'NA')
        {
            SearchedOpportunities =Database.query( strQueryFields+'Owner_Region__c=\''+ currentUserRegion +'\''+ strQueryFilters +' limit 50');


//          
//                                    where 
//                                    recordtype.name like '%PGi%' AND Owner.Name <> 'eCommerce Customer' AND Owner_Region__c=:currentUserRegion  AND NoISTNeeded__c = False AND CountofISTRecords__c=0 AND stagename <> 'Closed Lost' AND 
//                                    (((stagename = 'Purchase' OR Forecast_Status__c = 'Commit') AND closedate >= 2018-12-31) OR
//                                     (closedate >= 2018-12-31 AND stagename in ('Closed Won','Closed Won - Implementation','Closed Won - Implementation Complete'))) LIMIT 50];
        }
        else
        {
            SearchedOpportunities =Database.query(strQueryFields +'Owner_Region__c IN (\'APAC\',\'EMEA\')'+strQueryFilters + ' limit 50');

            //NumberofClosedOpportunities = [SELECT count() FROM Opportunity WHERE isClosed = true];
        }
        Integer count = 0;
        if(SearchedOpportunities.size() >0) {
            OpportunityList = new List<oOpportunity>();
            for(Opportunity c: SearchedOpportunities ) {
                // As each Opportunity is processed we create a new oOpportunity object and add it to the OpportunityList
                OpportunityList.add(new oOpportunity(c));
                if(c.isClosed == true){
                   count += 1; 
                }
            }  Flag=true; NumberofClosedOpportunities = count;
        }
    }
    
    public String sortExpression
    {
        get
        {  //system.debug('..sortExp..'+sortExp);
         
         return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            //system.debug('..value..'+value);
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }  
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }  
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    } 
    
    //************ method that is called when user clicks on column to sort
    public pagereference ViewData() 
    { //build the full sort expression

        string sortFullExp = sortExpression  + ' ' + sortDirection;
        //System.debug('sortFullExp>>>>>>>> '+sortFullExp);
        string ISTEligible='yes';
        
        //if (PGIAppConstants.USER_REGIONS[1].equals(currentUserRegion))
        if(currentUserRegion == 'NA')
        {
            
            SearchedOpportunities =Database.query( strQueryFields+'Owner_Region__c=\''+ currentUserRegion +'\''+ strQueryFilters +
                                                  'order by '+ sortFullExp + ' limit 50');
        }
        else
        {
            SearchedOpportunities =Database.query(strQueryFields +'Owner_Region__c IN (\'APAC\',\'EMEA\')'+strQueryFilters+
                                                  'order by ' + sortFullExp + ' limit 50');
        }
        
        OpportunityList = new List<oOpportunity>();
        
        for(Opportunity c: SearchedOpportunities ) 
        {
            OpportunityList.add(new oOpportunity(c));
        }
        
        return null; 
    }
    
    
    // **** Opportunity Wrapper Class***
    
    public class oOpportunity {
        public Opportunity con {get; set;}
        public Boolean selected {get; set;}

        
        //This is the contructor method. When we create a new oOpportunity object we pass a Opportunity that is set to the con property. We also set the selected value to false
        public oOpportunity(Opportunity c) {
            con = c;
            selected = false;
        }
    }
    //**** Class to create a child implementation record for the selected opportunity. On click of New Automated Button
    
    
    
    public PageReference CreateImpSerRecord() {
        
        List<Opportunity> selectedOpportunitys = new List<Opportunity>();
        
        //We will cycle through our list of oOpportunitys and will check to see if the selected property is set to true, if it is we add the Opportunity to the selectedOpportunitys list
        
        if(Flag==true) {
            
            for(oOpportunity cCon:OpportunityList) {
                if(cCon.selected == true) {
                    selectedOpportunitys.add(cCon.con);
                }
            }
            
            
            // Now we have our list of selected Opportunitys and can perform any type of logic we want, sending emails, updating a field on the Opportunity, etc
            //System.debug('These are the selected Opportunitys...');
            for(Opportunity con: selectedOpportunitys) {
                //system.debug(con);
            }
            
            //system.debug('------selectedOpportunitys------'+selectedOpportunitys);  
            
            if(selectedOpportunitys.size()>0)
            {  //system.debug('### -- Got some selected records' );
             
             for(Opportunity oo: selectedOpportunitys)
             {  
                 Implementation_Services__c Imp =new Implementation_Services__c();
                 
                 //Imp.Implementation_Owner__c='005e0000001YTG5';
                 Imp.Implementation_Owner__c='005a000000AoISB';
                 Imp.Implementation_Type__c='N/A';
                 Imp.IST_Status__c=  'No IS Assigned';
                 Imp.IST_Completed_Status__c ='No IS Assigned';
                 Imp.Related_Opportunity__c=oo.id;         
                 
                 Insert Imp;
                 //ImplementationInsertList.add(Imp) ;
             }     
             
             /*  if(ImplementationInsertList.size()>0)
{   Insert ImplementationInsertList;
} */
             
            }
        }
        
        if(Flag==false  ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Atleast one or more opportunities should be selected to perform this operation. Please select opportunities after finding some records'));
            return null;
        }
        
        if(selectedOpportunitys.size()==0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Atleast one or more opportunities should be selected to perform this operation. Please select opportunities after finding some records'));
            return null;
        }
        PageReference ref = Page.OpportunityImplementationAutomation;
        ref.setRedirect(true);
        return ref;
        
        
    }
    // RT 122-------------------------------------------------------/
    public void NoISTNeeded(){
        
        List<Opportunity> selectedOpportunitys = new List<Opportunity>();
        
        //We will cycle through our list of oOpportunitys and will check to see if the selected property is set to true, if it is we add the Opportunity to the selectedOpportunitys list
        Set<oOpportunity> OpportunitySet = new Set<oOpportunity>();
        List<Opportunity> OpportunityUpadated = new List<Opportunity>();
        OpportunitySet.addAll(OpportunityList);
        for(oOpportunity cCon:OpportunitySet) {
            if(cCon.selected == true) {
                selectedOpportunitys.add(cCon.con);
                OpportunitySet.remove(cCon);
            }
        }
        for(Opportunity objId :selectedOpportunitys){
            
            objId.NoISTNeeded__c  = True;
            OpportunityUpadated.add(objId);
        }
        OpportunityList.clear();
        OpportunityList.addAll(OpportunitySet);
        UPDATE OpportunityUpadated;
        //system.debug('-----Updatedlist--->>>'+OpportunityUpadated);
        
        
        
    }
    
    
    
    public PageReference GoToOpportunityLink() {
        
        OpportunityRefID=System.currentPageReference().getParameters().get('OpportunityRefID');
        
        //system.debug('------OpportunityRefID------'+OpportunityRefID); 
        PageReference pageRef = new PageReference('/'+OpportunityRefID);
        
        return pageRef ;
    }
    
}