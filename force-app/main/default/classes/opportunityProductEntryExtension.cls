public with sharing class opportunityProductEntryExtension {
    public class CustomException extends Exception{}
    public Opportunity theOpp {get;set;}
    public String searchString {get;set;}
    public opportunityLineItem[] shoppingCart {get;set;}
    public priceBookEntry[] AvailableProducts {get;set;}
    public Pricebook2 theBook {get;set;}  
    public String prodname{get;set;} 
    public Map<String, List<SelectOption>> ShoppingCartBillFreqOptions {get;set;}
    public Map<String, List<SelectOption>> ShoppingCartUnitTypeOptions {get;set;}
    public Map<String, String> ShoppingCartExistingService {get;set;}
    public Map<String, String> ShoppingCartMinCommitment {get;set;}
    public String toSelect {get; set;}
    public String rowIndex {get;set;}
    public Decimal Total {get;set;}
    public String boolvalue {get;set;}
    
    public Boolean overLimit {get;set;}
    public Boolean error {get;set;}
    public Boolean multipleCurrencies {get; set;}
    public Boolean isCurrentUserAdmin {get;set;}
    private Boolean forcePricebookSelection = false;
    
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};
    //public String query {get;set;}
    public opportunityProductEntryExtension(ApexPages.StandardController controller) {
    
        
        // Need to know if org has multiple currencies enabled
        multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
        isCurrentUserAdmin = PGIAppConstants.ADMIN_PROFILES.contains(UserInfo.getProfileId());
        // Get information about the Opportunity being worked on
        if(multipleCurrencies)
            theOpp = database.query('select Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode from Opportunity where Id = \'' + controller.getRecord().Id + '\' limit 1');
        else
            theOpp = [select Id, Pricebook2Id, PriceBook2.Name from Opportunity where Id = :controller.getRecord().Id limit 1];
        
        // If products were previously selected need to put them in the "selected products" section to start with
        shoppingCart = [select Id,New_Quantity__c, Active_Host_NA_Only__c, Min_Commit__c, Existing_Service__c, New_Sales_Price__c, Unit_Type__c, Billing_Frequency__c, Contract_Term__c, TotalPrice, UnitPrice, Description, PriceBookEntryId, PriceBookEntry.Name, PriceBookEntry.IsActive, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.Unit_Type_Options__c,PriceBookEntry.Product2.Billing_Frequency_options__c,PriceBookEntry.PriceBook2Id, Initial_Bill_Date__c, X100_Ramp_Date__c from opportunityLineItem where OpportunityId=:theOpp.Id order by PriceBookEntry.Product2.Name, Id];
        ShoppingCartBillFreqOptions = getBillFreqOptions();
        ShoppingCartUnitTypeOptions = getUnitTypeOptions();
        ShoppingCartExistingService = getExistingService();
        ShoppingCartMinCommitment = getMinCommitment();
        // Check if Opp has a pricebook associated yet
        if(theOpp.Pricebook2Id == null){
            Pricebook2[] activepbs = [select Id, Name from Pricebook2 where isActive = true limit 2];
            if(activepbs.size() == 2){
                forcePricebookSelection = true;
                theBook = new Pricebook2();
            }
            else{
                theBook = activepbs[0];
            }
        }
        else{
            theBook = theOpp.Pricebook2;
        }
        
        if(!forcePricebookSelection)
            updateAvailableList();
    }
    

       
    public String getChosenCurrency(){
    
        if(multipleCurrencies)
            return (String)theOpp.get('CurrencyIsoCode');
        else
            return '';
    }

    public void updateAvailableList() {
    
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'select Id, Pricebook2Id, IsActive, Product2.Unit_Type_Options__c,Product2.Billing_Frequency_options__c,Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice,Product_Existing_Service__c,Product_Min_Commitment_Eligible__c from PricebookEntry where IsActive=true and Product_RecordType_Name__c LIKE \'%PGi%\' and Product2.Name != \'PGI Standard Product\' and Pricebook2Id = \'' + theBook.Id + '\'';
        if(multipleCurrencies)
            qstring += ' and CurrencyIsoCode = \'' + theOpp.get('currencyIsoCode') + '\'';
        
        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if(searchString != null && searchString != ''){
            qString+= ' and (Product2.Name like \'%' + searchString + '%\' or Product2.Description like \'%' + searchString + '%\')';
        }
        
       
        Id currentProfileId = UserInfo.getProfileId();
        Boolean filterRegion = false; //include close bracket if region is filtered
        User currentUser = [SELECT User_Region__c, Channel__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(!PGIAppConstants.ADMIN_PROFILES.contains(currentProfileId) && !PGIAppConstants.GCS_DIAMOND_PROFILES.contains(currentProfileId)){
            if(currentUser.User_Region__c != null && currentUser.User_Region__c != '' && currentUser.User_Region__c != 'None'){
                qString += ' and (Product2.Region__c = \'ALL\' or Product2.Region__c includes (\'' + currentUser.User_Region__c + '\')';
                filterRegion = true;
            }
            if(currentUser.Channel__c != null && currentUser.Channel__c != '' && currentUser.Channel__c != 'None'){
                qString += ' or Product2.Channel_to_Included__c includes (\'' + currentUser.Channel__c + '\'))';
                qString += ' and Product2.Channel_to_Excluded__c excludes (\'' + currentUser.Channel__c + '\')';
            }
            else if (filterRegion){
                qString += ')';
            }
        }
        
        qString+= ' order by Product2.Name';
        qString+= ' limit 101';
        
        error = false;
        
        try{        
            AvailableProducts = database.query(qString);
            //query = qString + '; size='+AvailableProducts.size();
                        
            // We only display up to 100 results... if there are more than we let the user know (see vf page)
            if(AvailableProducts.size()==101){
                AvailableProducts.remove(100);
                overLimit = true;
            }
            else{
                overLimit=false;
            }
        }
        catch(Exception ex){
            error = true;
        }
    }

   
    public Map<String, List<SelectOption>> getBillFreqOptions() {
        Map<String, List<SelectOption>> billfreqoptns = new Map<String, List<SelectOption>>();
        List<Product2> allprodlist = [Select id,name,billing_frequency_options__c from product2 where recordtype.name like '%PGi%' and isActive=True];
        for(Product2 prd : allprodlist) {
            if(prd.Billing_Frequency_Options__c <> NULL){
                List<SelectOption> options = new List<SelectOption>();
                if(prd.Billing_Frequency_Options__c.split(';').size() > 1) {
                    options.add(new Selectoption('','-Select-'));
                }
                List<String> productbillfreqoptions = new List<String> (prd.Billing_Frequency_Options__c.split(';'));
                for (String str: productbillfreqoptions) {
                    SelectOption op = new SelectOption(str, str);
                    options.add(op);
                }
                billfreqoptns.put(prd.name, options);
            }
        }
        return billfreqoptns;
    }
    
    public Map<String, List<SelectOption>> getUnitTypeOptions() {
        Map<String, List<SelectOption>> unittypeoptns = new Map<String, List<SelectOption>>();
        List<Product2> allprodlist = [Select id,name,unit_type_options__c from product2 where recordtype.name like '%PGi%' and isActive=True];
        for(Product2 prd : allprodlist){
            if(prd.unit_type_options__c <> NULL){
                List<SelectOption> options = new List<SelectOption>();
                if(prd.Unit_Type_Options__c.split(';').size() > 1) {
                    options.add(new Selectoption('','-Select-'));    
                }
                List<String> productunittypeoptions = new List<String> (prd.Unit_Type_Options__c.split(';'));
                for (String str: productunittypeoptions) {
                    SelectOption op = new SelectOption(str, str);
                    options.add(op);
                }
                unittypeoptns.put(prd.name, options);
            }    
        }
        return unittypeoptns;
    }    
    
    public Map<String, String> getExistingService() {
    Map<String, String> prodexistingservice = new Map<String, String>();
    List<Product2> allprodlist = [Select id,name,existing_service_eligible__c from product2 where recordtype.name like '%PGi%' and isactive=True];
    for(Product2 prd : allprodlist){
        String boolvalue;
        if(prd.existing_service_eligible__c == True)
            boolvalue = 'False';
        else
            boolvalue = 'True'; 
        prodexistingservice.put(prd.name,boolvalue);        
        }    
    return prodexistingservice;
    }  
    
    public Map<String, String> getMinCommitment() {
    Map<String, String> prodmincommitment = new Map<String, String>();
    List<Product2> allprodlist = [Select id,name,Min_Commitment_Eligible__c from product2 where recordtype.name like '%PGi%' and isactive=True];
    for(Product2 prd : allprodlist){
        String boolvalue;
        if(prd.Min_Commitment_Eligible__c == True)
            boolvalue = 'False';
        else
            boolvalue = 'True'; 
        prodmincommitment.put(prd.name,boolvalue);        
        }    
    return prodmincommitment;
    }  
    
    public void addToShoppingCart(){
    
        // This function runs when a user hits "select" button next to a product
    
        for(PricebookEntry d : AvailableProducts){
            if((String)d.Id==toSelect){
                shoppingCart.add(new opportunityLineItem(Opportunity = theOpp,OpportunityId=theOpp.Id, PriceBookEntry=d, PriceBookEntryId=d.Id, UnitPrice=d.UnitPrice));
                break;
            }
        }
        updateAvailableList();  
    }
    

    public PageReference removeFromShoppingCart(){
    
        // This function runs when a user hits "remove" on an item in the "Selected Products" section
        Integer selectedRowIndex = Integer.valueOf(rowIndex);
        OpportunityLineItem oli = shoppingCart[selectedRowIndex];
        if(oli != null && oli.Id != null){
            forDeletion.add(oli);
        }
        shoppingCart.remove(selectedRowIndex);
        updateAvailableList();
        
        return null;
    }
    
    public PageReference onSave(){
        
        // Validate required fields
        Boolean isError = false;
        for(opportunityLineItem d : shoppingCart){
                if(d.New_Quantity__c == null){
                d.New_Quantity__c.addError('You must enter a value');
                isError = true;
            }
            if(d.New_Sales_Price__c == null){
                d.New_Sales_Price__c.addError('You must enter a value');
                isError = true;
            }
            if(d.Unit_Type__c == null){
                d.Unit_Type__c.addError('You must enter a value');
                isError = true;
            }
            if(d.Billing_Frequency__c == null){
                d.Billing_Frequency__c.addError('You must enter a value');
                isError = true;
            }
            if(d.Contract_Term__c == null){
                d.Contract_Term__c.addError('You must enter a value');
                isError = true;
            }
        }
        
        if(isError)
                return null;
        
        // If previously selected products are now removed, we need to delete them
        try{
        if(forDeletion.size()>0)
            delete(forDeletion);
            forDeletion.clear();
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            try{
                if(shoppingCart.size()>0)
                    upsert(shoppingCart);
            }
            catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }  
        }
         catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
   
        // After save return the user to the Opportunity
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public PageReference onCancel(){
 
        // If user hits cancel we commit no changes and return them to the Opportunity   
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public void deselectcheckbox()  {
        for(opportunityLineItem d : shoppingCart){
            d.min_commit__c = False; 
        }  
    }
    
    public PageReference redirect(){
    system.debug('ARC debug oppproductextension oppid:'+theopp.id);
    return null;
    }
    

}