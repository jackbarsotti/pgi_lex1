@isTest
public class ProductSymptomsTest {
    @testSetup static void setup(){
        List<Case_Product_Focus_Symptom__c> caseProdFocSympLst = new List<Case_Product_Focus_Symptom__c>{
            new Case_Product_Focus_Symptom__c(Name='Test',Product__c='*Non-Product/Consultative',Area_of_Focus__c='Testing',Symptom__c='Test1',Sub_Symptom__c='Test11')
                };
                    Insert caseProdFocSympLst;
    }
    static testmethod void testInit(){ 
        List<Case_Product_Focus_Symptom__c> caseProdFocSympLst = [SELECT Id, Area_of_Focus__c, Product__c, Sub_Symptom__c, Symptom__c FROM Case_Product_Focus_Symptom__c];
    System.debug('The list'+caseProdFocSympLst);
        ProductSymptoms obj = new ProductSymptoms();
        Map<String, Case_Product_Focus_Symptom__c> productFocusSymptomsMap = new Map<String, Case_Product_Focus_Symptom__c>();
        productFocusSymptomsMap.put(caseProdFocSympLst[0].Product__c,caseProdFocSympLst[0]);
        System.assertEquals(productFocusSymptomsMap, obj.getProducts());
        Set<String> productSet = new Set<String>();
        productSet.add(caseProdFocSympLst[0].Area_of_Focus__c);
        Map<String, Set<String>> productToAreaOfFocusMap = new Map<String, Set<String>>();
        productToAreaOfFocusMap.put(caseProdFocSympLst[0].Product__c, productSet);
        system.assertEquals(productToAreaOfFocusMap, obj.getAreaOfFocus());
        Set<String> symptomSet = new Set<String>();
        symptomSet.add(caseProdFocSympLst[0].Symptom__c);
        Map<String, Set<String>> areaOfFocusToSymptomMap = new Map<String, Set<String>>();
        areaOfFocusToSymptomMap.put(caseProdFocSympLst[0].Product__c + caseProdFocSympLst[0].Area_of_Focus__c,symptomSet);
        system.assertEquals(areaOfFocusToSymptomMap,obj.getSymptoms());
        system.assertEquals(areaOfFocusToSymptomMap,obj.getSubSymptoms());
    }
}