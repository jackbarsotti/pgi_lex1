/******************************************************************************
Name : PopulateOpportunityProductFamilies
Created By : Archana Rajendran
Description : Trigger to populate opportunity product families
******************************************************************************/
trigger PopulateOpportunityProductFamilies on Opportunity (before update) {
    
    if(setrecursivevariable.firstRun)
    {
        
        setrecursivevariable.firstRun = false;
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : Trigger.new)
        {
            //if(opp.isclosed == False)
                oppids.add(opp.Id);
        } 
        system.debug('ARC debug of oppids' +oppids);
        if(!oppids.isEmpty())
        {
            //List<Opportunity> oppstoupdate = new List<Opportunity>([Select id,Opportunity_Product_Families__c 
            //                                                        from opportunity 
            //                                                        where id IN :oppids]);   
            //system.debug('ARC debug of oppstoupdate' +oppstoupdate);
            
            List<OpportunityLineItem> allopplineitems = new List<OpportunityLineitem>([Select id,opportunityid,product_family__c from opportunitylineitem where opportunityid IN :oppids]);   
            system.debug('ARC debug of allopplineitems' +allopplineitems);
            Map<Id,Set<String>> opptolineitems = new Map<Id,Set<String>>();
            
            for (OpportunityLineItem oppli : allopplineitems)
            {
                if (!opptolineitems.containsKey(oppli.opportunityid)) 
                {
                    opptolineitems.put(oppli.opportunityid,new set<String>());
                }
                opptolineitems.get(oppli.opportunityid).add(oppli.product_family__c);
            }
            //system.debug('ARC debug of opptolineitems' +opptolineitems);
            for (Opportunity oppty : Trigger.new)
            {
                if(!opptolineitems.containsKey(oppty.id))
                {
                    oppty.Opportunity_Product_Families__c = '';
                }    
                else
                {
                    Set<String> oppprodfamilies = new Set<String>();
                    oppprodfamilies = opptolineitems.get(oppty.id);
                    //oppprodfamilies.sort();
                    List<String> oppprodfamilieslist = new List<String>(oppprodfamilies);
                    oppprodfamilieslist.sort();
                    
                    string collectionstring = '';
                    for (String s : oppprodfamilieslist)
                    {
                        collectionstring += (collectionstring==''?'':',')+s;
                    }
                    oppty.Opportunity_Product_Families__c = collectionstring;
                }
            }//for
            //update oppstoupdate; 
        }//ifnotempty
    }//ifrecursive
}