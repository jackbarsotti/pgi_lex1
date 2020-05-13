@isTest
global class iGlooConferenceRESTCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"results":[{"ConferenceId":"1171887","InstanceId":"1","Title":"Bank of America Source Marketing Conference","Start":\"\\/Date(1503925200000)\\/\","End":\"\\/Date(1503928800000)\\/\","LastModify":\"\\/Date(1503585579817)\\/\"}],"totalReturnedPages":0,"currentPage":1,"recordsFound":0}');
        res.setStatusCode(200);
        return res;
    }
}