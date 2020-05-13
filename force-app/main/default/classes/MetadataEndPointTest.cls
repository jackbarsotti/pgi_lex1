@isTest
public class MetadataEndPointTest {
    static testMethod void MetadataEndPoint(){
        Test.startTest();
        RestRequest req     = new RestRequest();
        RestResponse res    = new RestResponse();
        req.requestURI      = '/services/apexrest/MetadataEndPoint/Settings/Address';
        req.httpMethod      = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        MetadataEndPoint.getMetadata();
        Test.stopTest();
    }
}