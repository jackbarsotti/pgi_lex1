@IsTest
public class ImplementationServiceTriggerTest {
    @testSetup static void methodName() {
        Account acc= new Account();
        acc.Name='TestAccountSetImplementationOwnerOnOpportunity';
        acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'AL';
        acc.BillingPostalCode = '35630';
        acc.BillingStreet = '110 abc street';
        insert acc;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = system.today();
        opp1.StageName = 'Awareness';
        opp1.CurrencyIsoCode = 'USD';
        opp1.Products_of_Interest__c = 'Foxden';
        insert opp1;
        
        Product2 standardProduct = PGITestUtilities.getStdProduct();
        insert standardProduct;
        PricebookEntry standardPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct);
        insert standardPbe;
        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(opp1.Id, standardPbe.Id);
        insert oli; 
    }
    @IsTest
    public static void testImplementationServiceTrigger() {
        Opportunity opp1 =[Select Id,Name,AccountId,CloseDate,StageName,CurrencyIsoCode,Products_of_Interest__c from Opportunity where Name = 'test1'];
        Implementation_Services__c ImpSer = new Implementation_Services__c();
        ImpSer.IST_Status__c='Open';
        ImpSer.Implementation_Stage__c = 'Plan';
        ImpSer.Related_Opportunity__c=opp1.id;
        ImpSer.Implementation_Type__c ='Small Business <2K MMR';      
        //ImpSer.Implementation_Owner__c = u.Id;
        insert ImpSer;
        ImpSer.Implementation_Stage__c = 'On Hold';
        ImpSer.On_Hold_Notes__c = 'On Hold';
        update ImpSer;
        ImpSer = [SELECT Id,Date_of_Stage_Off_Hold__c,Date_of_Stage_On_Hold__c FROM Implementation_Services__c];
        System.assertEquals(null, ImpSer.Date_of_Stage_Off_Hold__c);
        System.assertEquals(System.today().format(), ImpSer.Date_of_Stage_On_Hold__c.format());
        ImpSer.Implementation_Stage__c = 'Plan';
        update ImpSer;
        ImpSer = [SELECT Id,Date_of_Stage_Off_Hold__c,Total_of_Days_on_Hold__c FROM Implementation_Services__c];
        System.assertEquals(0, ImpSer.Total_of_Days_on_Hold__c);
        System.assertEquals(System.today().format(), ImpSer.Date_of_Stage_Off_Hold__c.format());
        ImpSer.Implementation_Stage__c = 'On Hold';
        update ImpSer;   
        ImpSer.Implementation_Stage__c = 'Plan';
        ImpSer.Phase_1_Start_Date__c = System.today();
        ImpSer.Phase_1_Pause_Date__c = null;
        ImpSer.Phase_1_Pause_Days__c = null;
        ImpSer.Total_of_Days_on_Hold__c = 1;
        update ImpSer;
        ImpSer.IST_Completed_Status__c = 'Cancelled';
        ImpSer.Cancelled_Notes__c = 'Cancelled';
        update ImpSer;
        ImpSer.IST_Completed_Status__c = 'Nuture';
        update ImpSer;
        ImpSer = [SELECT Id, Phase_1_Pause_Date__c, Phase_2_Pause_Date__c, Phase_3_Pause_Date__c FROM Implementation_Services__c];
        System.assertNotEquals(null, ImpSer.Phase_1_Pause_Date__c);
        System.assertNotEquals(null, ImpSer.Phase_2_Pause_Date__c);
        System.assertNotEquals(null, ImpSer.Phase_3_Pause_Date__c);
    }
    @IsTest
    public static void testImplementationServiceTrigger1() {
        Opportunity opp1 =[Select Id,Name,AccountId,CloseDate,StageName,CurrencyIsoCode,Products_of_Interest__c from Opportunity where Name = 'test1'];
        Implementation_Services__c ImpSer = new Implementation_Services__c();
        ImpSer.IST_Status__c='Open';
        ImpSer.Implementation_Stage__c = 'Plan';
        ImpSer.Related_Opportunity__c=opp1.id;
        ImpSer.Implementation_Type__c ='Small Business <2K MMR';      
        //ImpSer.Implementation_Owner__c = u.Id;
        insert ImpSer;
        ImpSer.Implementation_Stage__c = 'On Hold';
        ImpSer.On_Hold_Notes__c = 'On Hold';
        update ImpSer;
        ImpSer = [SELECT Id,Date_of_Stage_Off_Hold__c,Date_of_Stage_On_Hold__c FROM Implementation_Services__c];
        System.assertEquals(null, ImpSer.Date_of_Stage_Off_Hold__c);
        System.assertEquals(System.today().format(), ImpSer.Date_of_Stage_On_Hold__c.format());
        ImpSer.Implementation_Stage__c = 'Plan';
        ImpSer.IST_Completed_Status__c='Open';   
        ImpSer.Total_of_Days_on_Hold__c = 0;
        ImpSer.Phase_1_Start_Date__c = System.today();
        ImpSer.Phase_1_Pause_Date__c = null;
        ImpSer.Phase_1_Pause_Days__c = null;  
        update ImpSer;  
        ImpSer = [SELECT Id,Phase_1_Pause_Days__c FROM Implementation_Services__c];
        System.assertEquals(0, ImpSer.Phase_1_Pause_Days__c);
        ImpSer.Implementation_Stage__c = 'On Hold';
        update ImpSer;
        ImpSer.Implementation_Stage__c = 'Build';
        ImpSer.IST_Completed_Status__c='Open';   
        ImpSer.Total_of_Days_on_Hold__c = 0;
        ImpSer.Phase_1_Start_Date__c = null;
        ImpSer.Phase_2_Start_Date__c = System.today();
        ImpSer.Phase_2_Pause_Date__c = null;
        ImpSer.Phase_2_Pause_Days__c = null;
        update ImpSer;  
        ImpSer = [SELECT Id,Phase_2_Pause_Days__c FROM Implementation_Services__c];
        System.assertEquals(0, ImpSer.Phase_2_Pause_Days__c);
        ImpSer.Implementation_Stage__c = 'On Hold';
        update ImpSer;
        ImpSer.Implementation_Stage__c = 'Train';
        ImpSer.IST_Completed_Status__c='Open';   
        ImpSer.Total_of_Days_on_Hold__c = 0;
        ImpSer.Phase_1_Start_Date__c = null;
        ImpSer.Phase_2_Start_Date__c = null;    
        ImpSer.Phase_3_Start_Date__c = System.today();
        ImpSer.Phase_3_Pause_Days__c = null;
        ImpSer.Phase_3_Pause_Date__c = null;
        update ImpSer;  
        ImpSer = [SELECT Id,Phase_3_Pause_Days__c FROM Implementation_Services__c];
        System.assertEquals(0, ImpSer.Phase_3_Pause_Days__c);
    }
    @IsTest
    public static void istCountDown() {
        Opportunity opp1 =[Select Id,Name,AccountId,CloseDate,StageName,CurrencyIsoCode,Products_of_Interest__c from Opportunity where Name = 'test1'];
        Implementation_Services__c ImpSer = new Implementation_Services__c();
        ImpSer.IST_Status__c='Open';
        ImpSer.Implementation_Stage__c = 'Plan';
        ImpSer.IST_Completed_Status__c = 'Open';
        ImpSer.Related_Opportunity__c=opp1.id;
        ImpSer.Implementation_Type__c ='Small Business <2K MMR';      
        //ImpSer.Implementation_Owner__c = u.Id;
        insert ImpSer;
        ImpSer.IST_Completed_Status__c='Nurture';
        Update ImpSer;
        ImpSer = [SELECT Id,Start_Nurture__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.Start_Nurture__c.format());	
        ImpSer.IST_Completed_Status__c='Open';
        Update ImpSer;
        ImpSer = [SELECT Id,End_Nurture__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.End_Nurture__c.format());
        ImpSer.Implementation_Stage__c = 'Train';
        ImpSer.Phase_1_Start_Date__c = System.today();
        ImpSer.Phase_1_Pause_Date__c = null;   
        update ImpSer;
        ImpSer = [SELECT Id,Phase_1_Pause_Date__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.Phase_1_Pause_Date__c.format());
        ImpSer.Implementation_Stage__c = 'Build';
        ImpSer.Phase_2_Start_Date__c = null;
        ImpSer.IST_Completed_Status__c = 'Open';   
        update ImpSer;
        ImpSer = [SELECT Id,Phase_2_Start_Date__c,Phase_2_End_Date__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.Phase_2_Start_Date__c.format());
        System.assertEquals(Date.today().addDays(28).format(), ImpSer.Phase_2_End_Date__c.format());
        ImpSer.Implementation_Stage__c = 'Train';
        ImpSer.Phase_2_Start_Date__c = System.today();
        ImpSer.Phase_2_Pause_Date__c = null;   
        update ImpSer;
        ImpSer = [SELECT Id,Phase_2_Pause_Date__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.Phase_2_Pause_Date__c.format());
        ImpSer.Implementation_Stage__c = 'Build';
        ImpSer.Phase_3_Start_Date__c = System.today();
        ImpSer.Phase_3_Pause_Date__c = null;   
        update ImpSer;
        ImpSer = [SELECT Id,Phase_3_Pause_Date__c FROM Implementation_Services__c];
        System.assertEquals(System.today().format(), ImpSer.Phase_3_Pause_Date__c.format());
        ApexPages.StandardController sc = new ApexPages.StandardController(ImpSer);	
        ISTCountdownTimer ext = new ISTCountdownTimer(sc);
        ISTCountdownTimer.refreshTimers(ImpSer.Id);
        
    }
}