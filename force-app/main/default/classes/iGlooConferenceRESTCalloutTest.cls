@isTest
public class iGlooConferenceRESTCalloutTest {
        @isTest Static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new iGlooConferenceRESTCalloutMock());
        iGlooConferenceRESTCallout.makeGETCallout();
        //HttpResponse res = iGlooConferenceRESTCallout.makeGETCallout();
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue = '{"success":true,"results":[{"ConferenceId":"1171887","InstanceId":"1","Title":"Bank of America Source Marketing Conference","Start":\"\\/Date(1503925200000)\\/\","End":\"\\/Date(1503928800000)\\/\","LastModify":\"\\/Date(1503585579817)\\/\"}],"totalReturnedPages":0,"currentPage":1,"recordsFound":0}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }
}