public Class PgiOpportunityTriggerUtilities{

    /*public static void assignPbToOppourtunity(list<Opportunity> opplst){ 

        assignStandardPbToOpp(opplst);
        
       

        // TODO: uncomment this line when pricebook changes takes place.
        //assignRegionWisePbToOpp(opplst);
    }
    
    private static void assignStandardPbToOpp(list<Opportunity> opplst)
    {
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        list<Opportunity> allOppDetails= opplst;
        Pricebook2 stdPb=new Pricebook2();
        try{
         stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
         for(Opportunity Opp: allOppDetails){
             
             if(rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('PGi'))
                 Opp.pricebook2id=stdPb.id;
          }
        }catch(Exception ex){
            system.debug(LoggingLevel.ERROR,'Error When Assigning region wise pricebook to opportunity '+ex.getMessage());
        }
    }
    

    */
    /**
     * Executes on after update opportunity trigger context.
     */
    //public static void onAfterUpdate()
    //{
        //updateOpportunityPricebook();
    //}
    
    /**
     * Collects the opportunity ids for which pricebook has been changed and then updates
     * the pricebook on the quotes created for the opportunity.
     */
   
    

    
    
               
     
     }