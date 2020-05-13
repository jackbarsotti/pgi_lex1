@isTest
public class MetadataRequestHandlerTest {
     static testMethod void retrieveRequest(){
         Test.startTest();
         Map<String,String> result = MetadataRequestHandler.retrieveRequest('/services/apexrest/MetadataEndPoint/Settings/Address');
         String asyncId = result.get('asyncResultID');
         MetadataRequestHandler.retrieveRequest('/services/apexrest/MetadataEndPoint/pollRequest/'+asyncId);
         Test.stopTest();        
     }
}