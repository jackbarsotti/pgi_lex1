@isTest
private class testAccountHierarchy{
    @TestSetup
     public static void createTestHierarchy(){
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('AccountReadyTalkTriggerHandler');
        OpportunityTriggerHandlerTest.bypassDlrs = true;
        InlineAcountHerachy_TestUtilities testUtils = new InlineAcountHerachy_TestUtilities();
        //Set of Fields should be checked
        Set<String> fieldsToCheck = new Set<String>{'AnnualRevenue', 'BillingCity','BillingCountry','BillingPostalCode','BillingState', 'BillingStreet', 'Description', 'ShippingCity', 'ShippingStreet', 'Name', 'ShippingState', 'ShippingPostalCode', 'ShippingCountry' };
        Test.startTest();
        //Create my Parent Account 
        testUtils.createAccounts( 1 , fieldsToCheck );
        testUtils.testAccList[0].Name = 'HierarchyTest0';
        testUtils.updateAccountList( fieldsToCheck );
        
        Account parentAccount = testUtils.testAccList[0];
        Id parentID = parentAccount.Id;
        System.Assert( parentID != null , 'Parent Id not found' );
        
        // Create 10 sub accounts
        testUtils.createAccounts( 5 , fieldsToCheck );
        Integer i = 0;
        for ( Account accAux : testUtils.testAccList ){ //Now i need change the names
            accAux.Name = 'HierarchyTest' + String.valueOf( i );
            i++;
        }
        testUtils.updateAccountList( fieldsToCheck );        
        
        List<Account> accountList = [ Select Id, parentID, name from account where name like 'HierarchyTest%' ORDER BY Name limit 10 ];
                
        for ( Integer x = 0; x < accountList.size(); x++ ){
            if ( accountList[x].name != 'HierarchyTest0' ){
                accountList[x].parentID = parentID;
                parentID = accountList[x].Id; 
            }
        }
        
        testUtils.testAccList.clear();
        testUtils.testAccList.addAll( accountList );
        testUtils.updateAccountList( fieldsToCheck );
        Test.stopTest();
        // Create 10 sub accounts
        Account subTreeParent = [ Select id, parentID, name from account where name = 'HierarchyTest4' limit 10 ];
        parentID = subTreeParent.Id;
        testUtils.createAccounts( 5, fieldsToCheck );
         
        i = 0;
        for ( Account accAux : testUtils.testAccList ){ //Now i need change the names
            accAux.Name = 'HierarchyTest' + '4.' + String.valueOf( i );
        }
        testUtils.updateAccountList( fieldsToCheck );

        List<Account> subAccountsList = [ Select Id, parentID, Name from Account where Name like 'HierarchyTest4%' limit 10  ];
        for ( Integer z = 1; z < subAccountsList.size(); z++ ){
            subAccountsList[z].parentID = parentID;
            parentID = accountList[z].Id; 
        }
        
        testUtils.testAccList.clear();
        testUtils.testAccList.addAll( subAccountsList );
    }
    static testMethod void testAccountHierarchy(){
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('AccountReadyTalkTriggerHandler');
        //AccountHierarchyTestData.createTestHierarchy();

        Account topAccount      = [ Select id, name from account where name = 'HierarchyTest0' limit 1 ];
        Account middleAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest2' limit 1 ];
        Account bottomAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest4' limit 1 ];
        Account[] accountList   = [ Select id, parentID, name from account where name like 'HierarchyTest%' ];

        
        
        PageReference AccountHierarchyPage = Page.AccountHierarchyPage;
        Test.setCurrentPage( AccountHierarchyPage );
        ApexPages.currentPage().getParameters().put( 'id', topAccount.id );
        
        // Instanciate Controller
        AccountStructure controller = new AccountStructure();
        
        // Call Methodes for top account
        controller.setcurrentId( null );
        AccountStructure.ObjectStructureMap[] smt1 = new AccountStructure.ObjectStructureMap[]{};
        smt1 = controller.getObjectStructure();
        System.Assert( smt1.size() > 0, 'Test failed at Top account, no Id' );
        Test.startTest();

        controller.setcurrentId( String.valueOf( topAccount.id ) );
        AccountStructure.ObjectStructureMap[] smt2 = new AccountStructure.ObjectStructureMap[]{};
        smt2 = controller.getObjectStructure();
        System.Assert( smt2.size() > 0, 'Test failed at Top account, with Id: '+smt2.size() );

        //Call ObjectStructureMap methodes
        smt2[0].setnodeId( '1234567890' );
        smt2[0].setlevelFlag( true );
        smt2[0].setlcloseFlag( false );
        smt2[0].setnodeType( 'parent' );
        smt2[0].setcurrentNode( false );
        smt2[0].setaccount( topAccount );
        
        String nodeId       = smt2[0].getnodeId();
        Boolean[] levelFlag = smt2[0].getlevelFlag();
        Boolean[] closeFlag = smt2[0].getcloseFlag();
        String nodeType     = smt2[0].getnodeType();
        Boolean currentName = smt2[0].getcurrentNode();
        Account smbAccount  = smt2[0].getaccount();

        // Call Methodes for middle account
        controller.setcurrentId( String.valueOf( middleAccount.id ) );
        AccountStructure.ObjectStructureMap[] smm = new AccountStructure.ObjectStructureMap[]{};
        smm = controller.getObjectStructure();
        System.Assert( smm.size() > 0, 'Test failed at middle account' );

        // Call Methodes for bottom account
        controller.setcurrentId( String.valueOf( bottomAccount.id ) );
        AccountStructure.ObjectStructureMap[] smb = new AccountStructure.ObjectStructureMap[]{};
        smb = controller.getObjectStructure();
        System.Assert( smb.size() > 0, 'Test failed at top account' );
        
        Test.stopTest();
    }
}