@isTest
private class OpportunityLineItemTest {
    static testMethod void testValidateExistingService() {
        /*
        Opportunity testOpp1 = PGITestUtilities.getOpportunityDetails();
        testOpp1.Type = 'Existing Cust- Existing Svc';
        insert testOpp1;
        Product2 testProduct = PGITestUtilities.getStdProduct();
        insert testProduct;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProduct);
        insert testPbe;
        OpportunityLineItem testOpli1 = PGITestUtilities.getOpportunityLineItemDetails(testOpp1.Id, testPbe.Id);
        testOpli1.Existing_Service__c = false;
        OpportunityLineItem testOpli2 = PGITestUtilities.getOpportunityLineItemDetails(testOpp1.Id, testPbe.Id);
        testOpli2.Existing_Service__c = false;
        User u = PGITestUtilities.getTestUser();
        u.Override_Validation_Rules__c = false;
        insert u;
        Test.startTest();
        System.runAs(u){
            //If Opp = Existing Cust- Existing Svc & OPLI Existing Service = False, error message is displayed
            try{
                insert testOpli1;
                system.assert(false);
            }
            catch(Exception ex){
                system.assert(true);
            }   
            
            //If Opp = Existing Cust- Existing Svc & OPLI Existing Service = True, no error saving record
            testOpli1.Existing_Service__c = true;
            insert testOpli1;
            insert testOpli2;
            
            //If Opp = Existing Cust- New Svc & OPLI Existing Service = False, no error saving record
            Opportunity testOpp2 = PGITestUtilities.getOpportunityDetails();
            testOpp2.Type = 'Existing Cust- New Svc';
            insert testOpp2;
            OpportunityLineItem testOpli3 = PGITestUtilities.getOpportunityLineItemDetails(testOpp2.Id, testPbe.Id);
            testOpli3.Existing_Service__c = false;
            insert testOpli3;
            testOpli3.Quantity = 12;
            update testOpli3;
        }
     
        Test.stopTest();
        */
        
        Id pricebookId = Test.getStandardPricebookId();
       Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X'
        );
        insert prod;

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;

        Pricebook2 customPB = new Pricebook2(
            Name='Custom Pricebook',
            isActive=true
        );
        insert customPB;

        Opportunity oppo = new Opportunity();
            oppo.StageName      = 'native activise';
            oppo.Name           = '3';
            //oppo.WFCE__WP_ID__c = '13';
            //po.MRR_c = 3;
            oppo.highest_MRR_Product_Value__c = -1;
            oppo.Pricebook2Id = pricebookId;
            oppo.CloseDate = Date.today();
        insert oppo;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppo.Id,
            Quantity = 20,
            Product2Id  = prod.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 10,
         Billing_Frequency__c ='Annually',
           iMCNRRProduct__c = FALSE, 
            iMCProduct__c = TRUE,
            Historic_Line_Item__c = TRUE,
            isReportable_Text__c = 'Invalid',
            Unit_Type__c='Ancillary',
            Contract_Term__c =0,
            New_Sales_Price__c = 12345,
            New_Quantity__c = 12
        );
        insert oli;
      OpportunityLineItem oliitems = new OpportunityLineItem(
        OpportunityId = oppo.Id,
            Quantity = 20,
            Product2Id  = prod.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 10,
         Billing_Frequency__c ='One Time Event',
           iMCNRRProduct__c = TRUE, 
            iMCProduct__c = TRUE,
            Historic_Line_Item__c = TRUE,
          New_Sales_Price__c = 123,
            New_Quantity__c = 5,
          Unit_Type__c='Ancillary',
           Legacy_MRR__c = 123
                   );
        insert oliitems;
    }
    /**
    * @description : this method is to test the NRR and ACV Values for Product hich has product family= 'Collaboration'
    * @author Anup Kage (anup@cloudfastener.com) | 1/7/2020 
    * @return testMethod 
    * @Ticket : RT-397
    **/
    static testMethod void testCollaboration() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                Family = 'Collaboration'
            );
            insert prod;

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;

            Pricebook2 customPB = new Pricebook2(
                Name='Custom Pricebook',
                isActive=true
            );
            insert customPB;

            Opportunity oppo = new Opportunity();
                oppo.StageName      = 'native activise';
                oppo.Name           = '3';
                oppo.highest_MRR_Product_Value__c = -1;
                oppo.Pricebook2Id = pricebookId;
                oppo.CloseDate = Date.today();
            insert oppo;

            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppo.Id,
                Quantity = 20,
                Product2Id  = prod.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 10,
                Billing_Frequency__c ='Annually',
                iMCNRRProduct__c = FALSE, 
                iMCProduct__c = TRUE,
                Historic_Line_Item__c = TRUE,
                isReportable_Text__c = 'Invalid',
                Unit_Type__c='Ancillary',
                Contract_Term__c =0,
                New_Sales_Price__c = 12,
                New_Quantity__c = 12
            );
            insert oli;
            system.assertEquals(oppo.Product_NRR_Total_Collab__c, oli.NRR__c);
            system.assertEquals(oppo.Product_ACV_Total_Collab__c, oli.Annual_Value__c);
    }
    /**
    * @description : this method is to test the NRR and ACV Values for Product hich has product family= 'Webinar'
    * @author Anup Kage (anup@cloudfastener.com) | 1/7/2020 
    * @return testMethod 
    * @Ticket : RT-397
    **/
   
/*    static testMethod void testWebinar() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                Family = 'Webinar'
            );
            insert prod;

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;

            Pricebook2 customPB = new Pricebook2(
                Name='Custom Pricebook',
                isActive=true
            );
            insert customPB;

            Opportunity oppo = new Opportunity();
                oppo.StageName      = 'native activise';
                oppo.Name           = '3';
                oppo.highest_MRR_Product_Value__c = -1;
                oppo.Pricebook2Id = pricebookId;
                oppo.CloseDate = Date.today();
            insert oppo;

            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppo.Id,
                Quantity = 20,
                Product2Id  = prod.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 10,
                Billing_Frequency__c ='Annually',
                iMCNRRProduct__c = FALSE, 
                iMCProduct__c = TRUE,
                Historic_Line_Item__c = TRUE,
                isReportable_Text__c = 'Invalid',
                Unit_Type__c='Ancillary',
                Contract_Term__c =0,
                New_Sales_Price__c = 12,
                New_Quantity__c = 12
            );
            insert oli;
            system.assertEquals(oppo.Product_NRR_Total_Webinar__c, oli.NRR__c);
            system.assertEquals(oppo.Product_ACV_Total_Webinar__c, oli.Annual_Value__c);
             }    */ 
    /**
    * @description : this method is to test the NRR and ACV Values for Product hich has product family= 'Webicast'
    * @author Anup Kage (anup@cloudfastener.com) | 1/7/2020 
    * @return testMethod 
    * @Ticket : RT-397
    **/ 
    static testMethod void testWebcast() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                Family = 'Webcast'
            );
            insert prod;

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;

            Pricebook2 customPB = new Pricebook2(
                Name='Custom Pricebook',
                isActive=true
            );
            insert customPB;

            Opportunity oppo = new Opportunity();
                oppo.StageName      = 'native activise';
                oppo.Name           = '3';
                oppo.highest_MRR_Product_Value__c = -1;
                oppo.Pricebook2Id = pricebookId;
                oppo.CloseDate = Date.today();
            insert oppo;

            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppo.Id,
                Quantity = 20,
                Product2Id  = prod.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 10,
                Billing_Frequency__c ='One Time Event',
                iMCNRRProduct__c = FALSE, 
                iMCProduct__c = TRUE,
                Historic_Line_Item__c = TRUE,
                isReportable_Text__c = 'Invalid',
                Unit_Type__c='Ancillary',
                Contract_Term__c =0,
                New_Sales_Price__c = 12,
                New_Quantity__c = 12
            );
            insert oli;
            // system.assertEquals(oppo.Product_ACV_Total_Webcast__c, oli.Annual_Value__c);
            // system.assertEquals(oppo.Product_NRR_Total_Webcast__c, oli.NRR__c); 
            
    }
    
}