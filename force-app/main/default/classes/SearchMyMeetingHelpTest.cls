@isTest
private class SearchMyMeetingHelpTest {

    private class SearchMyMeetingHelpTestMock implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().endsWith('shorten')) { //bitly
                res.setHeader('content-type', 'application/json');
                res.setBody('{"link":"https://bit.ly/mock"}');
                res.setStatusCode(200);
            }
            else { //mmh search
                res.setHeader('content-type', 'application/xml');
                res.setBody('<search><count>1</count><result><uri>https://www.mymeetinghelp.com/mocktitle</uri><title>Mock Page</title></result></search>');
                res.setStatusCode(200);
            }
            return res;
        }
    }

    static testMethod void getResultsMethod(){
        List<SearchMyMeetingHelp.Input> inputList = new List<SearchMyMeetingHelp.Input>();
        SearchMyMeetingHelp.Input input = new SearchMyMeetingHelp.Input();
        input.keywords = '';
        input.productArea = '';
        inputList.add(input);

        Test.setMock(HttpCalloutMock.class, new SearchMyMeetingHelpTestMock());
        List<SearchMyMeetingHelp.Output> outputList = SearchMyMeetingHelp.searchMyMeetingHelp(inputList);
        System.assertEquals(outputList[0].searchResultCount, 1);
        System.assertEquals(outputList[0].searchResultText, 'I found this article on our Success Center.\n\n1) Mock Page\nhttps://bit.ly/mock');
    }
}