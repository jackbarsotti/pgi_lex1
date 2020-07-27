public without sharing class ReadyTalkOppProductEntryExtension {

    public Opportunity theOpp {get;set;}
    public String searchString {get;set;}
    public opportunityLineItem[] shoppingCart {get;set;}
    public priceBookEntry[] AvailableProducts {get;set;}
    public Pricebook2 theBook {get;set;}   
    
    public String toSelect {get; set;}
    public Integer toUnselect {get; set;}
    public Decimal Total {get;set;}
    
    public Boolean overLimit {get;set;}
    public Boolean multipleCurrencies {get; set;}
    
    private Boolean forcePricebookSelection = false;
    
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};
    
    public Map<String, Schema.FieldSet> oppLineFsMap { get {
        return Schema.sObjectType.OpportunityLineItem.FieldSets.getMap();
        
    }} 
    public String fieldSetName {get {
            if(oppLineFsMap.get('AP_'+opptyRecordTypeName) != null) {
                fieldSetName = 'AP_'+opptyRecordTypeName;
            } else {
                fieldSetName = 'AP_Default';
            }
        return fieldSetName;
    } set;}

    private String opptyRecordTypeName {get {
        if(theOpp == null && opptyRecordTypeName == null) {
            return 'Default';
        } else if (opptyRecordTypeName == null) {
            opptyRecordTypeName = theOpp.RecordType.DeveloperName;
        }
        return opptyRecordTypeName;
    } set;}
    private Id theOppId { get{
        return theOpp.Id;
    }}
    private Set<String> shoppingCartFields = new Set<String>{'Id', 'Quantity', 'TotalPrice', 'UnitPrice', 'Description', 'PriceBookEntryId', 'PriceBookEntry.Name', 'PriceBookEntry.IsActive', 'PriceBookEntry.Product2Id', 'PriceBookEntry.Product2.Name', 'PriceBookEntry.PriceBook2Id'};
    public ReadyTalkOppProductEntryExtension(ApexPages.StandardController controller) {

        // Need to know if org has multiple currencies enabled
        multipleCurrencies = UserInfo.isMultiCurrencyOrganization();

        // Get information about the Opportunity being worked on
        if(multipleCurrencies)
            theOpp = Database.query('SELECT Id, RecordType.DeveloperName, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode from Opportunity WHERE Id = \'' + controller.getRecord().Id + '\' limit 1');
        else
            theOpp = [SELECT Id, Pricebook2Id, RecordType.DeveloperName, PriceBook2.Name FROM Opportunity WHERE Id = :controller.getRecord().Id limit 1];
        
        for(FieldSetMember field: oppLineFsMap.get(fieldSetName).getFields()) {
            shoppingCartFields.add(field.getFieldPath());
        }
        //TODO add fields FROM field set
        String shoppingCartQuery = 'SELECT ';
        for(String field: shoppingCartFields) {
            shoppingCartQuery += field + ',';
        }
        shoppingCartQuery = shoppingCartQuery.removeEnd(',');
        shoppingCartQuery += ' FROM OpportunityLineItem WHERE OpportunityId=:theOppId';
        System.debug(shoppingCartQuery);
        // If products were previously selected need to put them in the "selected products" section to start with
        shoppingCart = Database.query(shoppingCartQuery);


        // Check if Opp has a pricebook associated yet
        if(theOpp.Pricebook2Id == null){
            Pricebook2[] activepbs = [SELECT Id, Name FROM Pricebook2 WHERE isActive = true limit 2];
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
    
    // this is the 'action' method on the page
    public PageReference priceBookCheck(){
        String themeType = UserInfo.getUITheme();
       if(themeType=='Theme3'){
            // if the user needs to select a pricebook before we proceed we send them to standard pricebook selection screen
            if(forcePricebookSelection){        
                return changePricebook();
            }
            else{
            
                //if there is only one active pricebook we go with it and save the opp
                if(theOpp.pricebook2Id != theBook.Id){
                    try{
                        theOpp.Pricebook2Id = theBook.Id;
                        update(theOpp);
                    }
                    catch(Exception e){
                        ApexPages.addMessages(e);
                    }
                }
                
                return null;
            }
        }else{
            return null;
        }
    }
       
    public String getChosenCurrency(){
    
        if(multipleCurrencies)
            return (String)theOpp.get('CurrencyIsoCode');
        else
            return '';
    }

    public void updateAvailableList() {
    
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'select Id, Pricebook2Id, IsActive, Product2.ProductCode, Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice FROM PricebookEntry WHERE IsActive=true and Pricebook2Id = \'' + theBook.Id + '\'';
        if(multipleCurrencies)
            qstring += ' and CurrencyIsoCode = \'' + theOpp.get('currencyIsoCode') + '\'';
        
        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if(searchString!=null){
            searchString = searchString.trim();
            qString+= ' and (Product2.Family like \'%'+searchString+'%\' or Product2.Name like \'%' + searchString + '%\' or Product2.Description like \'%' + searchString + '%\' or Product2.ProductCode like \'%' + searchString + '%\')';
        }
        
        Set<Id> selectedEntries = new Set<Id>();
        for(opportunityLineItem d:shoppingCart){
            selectedEntries.add(d.PricebookEntryId);
        }
        
        //if(selectedEntries.size()>0){
        //    String tempFilter = ' and Id not in (';
        //    for(Id i : selectedEntries){
        //        tempFilter+= '\'' + (String)i + '\',';
        //    }
        //    String extraFilter = tempFilter.substring(0,tempFilter.length()-1);
        //    extraFilter+= ')';
            
        //    qString+= extraFilter;
        //}
        
        qString+= ' order by Product2.Name';
        qString+= ' limit 101';
        
        system.debug('qString:' +qString);        
        AvailableProducts = Database.query(qString);
        
        // We only display up to 100 results... if there are more than we let the user know (see vf page)
        if(AvailableProducts.size()==101){
            AvailableProducts.remove(100);
            overLimit = true;
        }
        else{
            overLimit=false;
        }
    }
    
    public void addToShoppingCart(){
    
        // This function runs when a user hits "select" button next to a product
    
        for(PricebookEntry d : AvailableProducts){
            if((String)d.Id==toSelect){
                shoppingCart.add(new opportunityLineItem(OpportunityId=theOpp.Id, PriceBookEntry=d, PriceBookEntryId=d.Id, UnitPrice=d.UnitPrice));
                break;
            }
        }
        updateAvailableList();  
    }
    

    public PageReference removeFromShoppingCart(){
    
        // This function runs when a user hits "remove" on an item in the "Selected Products" section
        Integer indexToRemove = Integer.valueof(System.currentPageReference().getParameters().get('index'));
        System.debug(indexToRemove);
        //Integer count = 0;
        if(indexToRemove != null && indexToRemove > -1) {
            shoppingCart.remove(indexToRemove);
        }   
        //for(opportunityLineItem d : shoppingCart){
        //    if((String)d.PriceBookEntryId==toUnselect){
            
        //        if(d.Id!=null)
        //            forDeletion.add(d);
            
        //        shoppingCart.remove(count);
        //        break;
        //    }
        //    count++;
        //}
        
        updateAvailableList();
        
        return null;
    }
    
    public PageReference onSave(){
    
        // If previously selected products are now removed, we need to delete them
        if(forDeletion.size()>0)
            delete(forDeletion);
    
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        try{
            if(shoppingCart.size()>0){
                //for(OpportunityLineItem oli: shoppingCart) {
                //    if(oli.UnitPrice == 0) {
                //        //oli.TotalPrice = 0;
                //        //oli.UnitPrice = null;
                //    }
                //}
                OpportunityTriggerHandler.bypassContactRole = true;
                upsert(shoppingCart);
                OpportunityTriggerHandler.bypassContactRole = false;
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
    
    public PageReference changePricebook(){
    
        // This simply returns a PageReference to the standard Pricebook selection screen
        // Note that is uses retURL parameter to make sure the user is sent back after they choose
    
        PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
        ref.getParameters().put('id',theOpp.Id);
        ref.getParameters().put('retURL','/apex/opportunityProductEntry?id=' + theOpp.Id);
        
        return ref;
    }
}