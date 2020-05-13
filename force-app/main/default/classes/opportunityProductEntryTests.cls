@istest
private class opportunityProductEntryTests {
    //@isTest(SeeAllData=true)
    //private static void Test_opportunityProductEntry(){     
    //    Test.startTest();
    //    Profile testProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
    //    User testUser = PGITestUtilities.getTestUser(testProfile);
    //    testUser.User_Region__c = 'NA';
    //    testUser.Channel__c = 'Cloud';
    //    insert testUser;
        
    //    system.runAs(testUser){   
    //        Account testAccount = PGITestUtilities.getAccountDetails();
    //        testaccount.numberofemployees=5;
    //        testaccount.AnnualRevenue=100;
    //        insert testAccount;
    //        Product2 product = PGITestUtilities.getStdProduct();
    //        product.Region__c='ALL';
    //        product.Channel_to_Included__c = 'Major Accounts';
    //        insert product;
    //        PricebookEntry pbe = PGITestUtilities.CreatePriceBookEntryForProduct(product);
    //        insert pbe;
    //        Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
    //        testOpp.AccountId = testAccount.Id;
    //        insert testOpp;
    //        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(testOpp.Id, pbe.Id);
    //        oli.Opportunity = testOpp;
    //        oli.PricebookEntry = pbe;
    //        oli.Opportunity.AccountId = testAccount.Id;
    //        insert oli;  

    //        PageReference pageRef = Page.opportunityProductEntry;
    //        pageRef.getParameters().put('Id',testOpp.Id);
    //        Test.setCurrentPageReference(pageRef);
    //        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(oli.Opportunity));
            
    //        // test 'getChosenCurrency' method
    //        if(UserInfo.isMultiCurrencyOrganization())
    //            System.assert(oPEE.getChosenCurrency()!='');
    //        else
    //            System.assertEquals(oPEE.getChosenCurrency(),'');
    
    //        Integer startCount = oPEE.ShoppingCart.size();
    //        system.assert(startCount>0);
    
    //         //test search functionality without finding anything
    //        oPEE.searchString = 'michaelforce is a hip cat';
    //        oPEE.updateAvailableList();
    //        system.assert(oPEE.AvailableProducts.size()==0);
            
    //        // test search again, this time we will find something
    //        oPEE.searchString = oli.PricebookEntry.Name;
    //        oPEE.updateAvailableList();
    //        system.assert(oPEE.AvailableProducts.size()>0);       
    
    //        // test add to Shopping Cart function
    //        oPEE.toSelect = oPEE.AvailableProducts[0].Id;
    //        oPEE.addToShoppingCart();
    //        system.assert(oPEE.shoppingCart.size()>0);
                    
    //        // test save method - WITHOUT quanitities and amounts entered and confirm that error message is displayed
    //        oPEE.onSave();
    //        system.assert(ApexPages.getMessages().size()>0);
            
    //        // add required info and try save again
    //        for(OpportunityLineItem o : oPEE.ShoppingCart){
    //            o.quantity = 5;
    //            o.unitprice = 300;
    //        }
    //        oPEE.onSave();
    //        integer rowCount = oPEE.shoppingCart.size();        
    //        oPEE.rowIndex = '0';
    //        oPEE.removeFromShoppingCart();
    //        system.assert(oPEE.shoppingCart.size() == rowCount-1);
            
    //        // final quick check of cancel button
    //        System.assert(oPEE.onCancel()!=null);
    //    }

    //    Test.stopTest();
    //}
    
    private static testMethod void Test_opportunityProductRedirectExtension(){
        Test.startTest();
        Account testAccount = PGITestUtilities.getAccountDetails();
        insert testAccount;
        Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
        testOpp.AccountId = testAccount.Id;
        insert testOpp;
        Product2 product = PGITestUtilities.getStdProduct();
        insert product;
        PricebookEntry pbe = PGITestUtilities.CreatePriceBookEntryForProduct(product);
        insert pbe;
        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(testOpp.Id, pbe.Id);
        oli.Opportunity = testOpp;
        oli.PricebookEntry = pbe;
        oli.Opportunity.AccountId = testAccount.Id;
        insert oli;
        
        PageReference pageRef = Page.opportunityProductRedirect;
        pageRef.getParameters().put('Id',oli.Id);
        Test.setCurrentPageReference(pageRef);
        opportunityProductRedirectExtension oPRE = new opportunityProductRedirectExtension(new ApexPages.StandardController(oli));
        PageReference pageRef2 = oPRE.redirect();
        Test.stopTest();
        system.assert(pageRef2.getUrl().contains('opportunityProductEntry'));
    }
    // for IMC account record type
    private static testMethod void Test_IMCAccRT_opportunityProductRedirectExtension(){
        Test.startTest();
        Account testAccount = PGITestUtilities.getAccountDetails();
        insert testAccount;
        Id oppIMCRecordtypeId = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name LIKE '%IMC%' LIMIT 1].id;
        Opportunity testOpp = new Opportunity(Name = 'TestOpportunity',StageName = 'Awareness',CloseDate = date.today() + 10,
                                              Opportunity_Source_Open__c = 'None',recordtypeid = oppIMCRecordtypeId);
        insert testOpp;
        //Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
        //testOpp.AccountId = testAccount.Id;
        //insert testOpp;
        Product2 product = PGITestUtilities.getStdProduct();
        insert product;
        PricebookEntry pbe = PGITestUtilities.CreatePriceBookEntryForProduct(product);
        insert pbe;
        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(testOpp.Id, pbe.Id);
        oli.Opportunity = testOpp;
        oli.PricebookEntry = pbe;
        oli.Opportunity.AccountId = testAccount.Id;
        insert oli;
        
        PageReference pageRef = Page.opportunityProductRedirect;
        pageRef.getParameters().put('Id',oli.Id);
        Test.setCurrentPageReference(pageRef);
        opportunityProductRedirectExtension oPRE = new opportunityProductRedirectExtension(new ApexPages.StandardController(oli));
        PageReference pageRef2 = oPRE.redirect();
        Test.stopTest();
        system.assert(pageRef2.getUrl().contains('OpportunityProductEditPage'));
    }
}