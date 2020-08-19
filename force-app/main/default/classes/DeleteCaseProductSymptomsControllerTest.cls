@isTest
public class DeleteCaseProductSymptomsControllerTest {
    
    @isTest
    public static void testDeleteRecords() {
        
        Case_Product_Focus_Symptom__c caseProdFocSymptObj=new Case_Product_Focus_Symptom__c();
        caseProdFocSymptObj.Name='testCaseProd';
        INSERT caseProdFocSymptObj; 
        
        Case_Product_Focus_Symptom__c caseProdFoSyObj=new Case_Product_Focus_Symptom__c();
        caseProdFoSyObj.Name='testCaseProdDelete1';
        INSERT caseProdFoSyObj; 
        
        List<Case_Product_Focus_Symptom__c> caseProdFocSymptList = New List<Case_Product_Focus_Symptom__c>();
        caseProdFocSymptList.add(caseProdFocSymptObj);
        caseProdFocSymptList.add(caseProdFoSyObj);
        
        Test.StartTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caseProdFocSymptList);
        sc.setSelected(caseProdFocSymptList);
        DeleteCaseProductSymptomsController delCaseProdObj=new DeleteCaseProductSymptomsController(sc);
        delCaseProdObj.deleteRecords();
        delCaseProdObj.returnToHomepage();
        Test.StopTest();
        Integer caseProdCount = [SELECT COUNT() 
                                 FROM Case_Product_Focus_Symptom__c];
        System.assert(caseProdCount==0);      
    }
}