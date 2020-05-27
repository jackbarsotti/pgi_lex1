@istest
private class SFQuestion_Test {
    @istest
    private static void testQuestionController(){
        Survey_Question__c sq= new Survey_Question__c();
        sq.Name =  'Test';
        sq.Question__c = 'Question';
        sq.Choices__c = 'Test1\nTest2';
        sq.Type__c = 'Single Select--Vertical';
        sq.Required__c = True;
        sq.OrderNumber__c = 1;

        SFQuestion q = new SFQuestion(sq);
        System.assertEquals(q.singleOptions.size(), 2);
        
        
        Survey_Question__c sq2= new Survey_Question__c();
        sq2.Name =  'Test2';
        sq2.Question__c = 'Question';
        sq2.Choices__c = 'Test1\nTest2';
        sq2.Type__c = 'Multi-Select--Vertical';
        sq2.Required__c = False;
        sq2.OrderNumber__c = 2;

        SFQuestion q2 = new SFQuestion(sq2);
        System.assertEquals(q2.multiOptions.size(), 2);
        
        
        
        Survey_Question__c sq3= new Survey_Question__c();
        sq3.Name =  'Test3';
        sq3.Question__c = 'Question';
        sq3.Choices__c = 'Test1\nTest2';
        sq3.Type__c = 'Single Select--Horizontal';
        sq3.Required__c = False;
        sq3.OrderNumber__c = 3;

        SFQuestion q3 = new SFQuestion(sq3);
        System.assertEquals(q3.rowOptions.size(), 2);
        
        
        
        Survey_Question__c sq4= new Survey_Question__c();
        sq4.Name =  'Test4';
        sq4.Question__c = 'Question';
        sq4.Type__c = 'Free Text - Single Row Visible';
        sq4.Required__c = False;
        sq4.OrderNumber__c = 4;

        SFQuestion q4 = new SFQuestion(sq4);
        
    }
    
}