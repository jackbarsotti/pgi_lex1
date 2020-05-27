public with sharing class SearchMyMeetingHelp {

    public class Input {
        @InvocableVariable(required=true)
        public String keywords;

        @InvocableVariable(required=false)
        public String productArea;
    }
    
    public class Output {
        @InvocableVariable()
        public Integer searchResultCount = 0;

        @InvocableVariable()
        public String searchResultText;
    }

    public class SearchResult {
        public String articleTitle;
        public String articleUri;
    }

    @InvocableMethod(label='Search MyMeetingHelp.com')
    public static List<Output> searchMyMeetingHelp(List<Input> inputs) {

        Input input = inputs[0];
        Output output = new Output();

        List<String> fluffWords = new List<String> {
            'i',
            'me',
            'my',
            'myself',
            'we',
            'our',
            'ours',
            'ourselves',
            'you',
            'your',
            'yours',
            'yourself',
            'yourselves',
            'he',
            'him',
            'his',
            'himself',
            'she',
            'her',
            'hers',
            'herself',
            'it',
            'its',
            'itself',
            'they',
            'them',
            'their',
            'theirs',
            'themselves',
            'what',
            'which',
            'who',
            'whom',
            'this',
            'that',
            'these',
            'those',
            'am',
            'is',
            'are',
            'was',
            'were',
            'be',
            'been',
            'being',
            'have',
            'has',
            'had',
            'having',
            'do',
            'does',
            'did',
            'doing',
            'a',
            'an',
            'the',
            'and',
            'but',
            'if',
            'or',
            'because',
            'as',
            'until',
            'while',
            'of',
            'at',
            'by',
            'for',
            'with',
            'about',
            'against',
            'between',
            'into',
            'through',
            'during',
            'before',
            'after',
            'above',
            'below',
            'to',
            'from',
            'up',
            'down',
            'in',
            'out',
            'on',
            'off',
            'over',
            'under',
            'again',
            'further',
            'then',
            'once',
            'here',
            'there',
            'when',
            'where',
            'why',
            'how',
            'all',
            'any',
            'both',
            'each',
            'few',
            'more',
            'most',
            'other',
            'some',
            'such',
            'no',
            'nor',
            'not',
            'only',
            'own',
            'same',
            'so',
            'than',
            'too',
            'very',
            'can',
            'will',
            'just',
            'don\'t',
            'should',
            'now'
        };
        List<String> keywordsArr = input.keywords.split(' ');
        String newKeywords = '';
        for(String keyword: keywordsArr) {
            if(fluffWords.indexOf(keyword.toLowerCase()) == -1) {
                if(newKeywords != '') {newKeywords += ' ';}
                newKeywords += keyword;
            }
        }
        if(newKeywords.trim() == '') {
            newKeywords = input.keywords;
        }

        String searchConstraint = 'type:wiki';
        switch on input.productArea {
            when 'Web or Audio Meetings' {
                searchConstraint += ' AND (path:Home/Meetings/* OR path:Home/Audio/*)';
            }
            when 'Operator Assisted Events' {
                searchConstraint += ' AND path:Home/Events/*';
            }
            when 'Business Phone Systems' {
                searchConstraint += ' AND path:Home/Phone/*';
            }
        }
        //String fullSearchResultsUri = 'https://www.mymeetinghelp.com/Special:Search?qid=&fpid=230&fpth=&query=' + EncodingUtil.urlEncode(input.keywords, 'UTF-8') + '&type=wiki';

        //get search results using http client
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.mymeetinghelp.com/@api/deki/site/search?q=' + EncodingUtil.urlEncode(newKeywords, 'UTF-8') + '&format=search&constraint=' + EncodingUtil.urlEncode(searchConstraint, 'UTF-8') + '&limit=3');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Dom.Document doc = response.getBodyDocument();
        
        //get result data using xml reader
        List<SearchResult> searchResults = new List<SearchResult>();
        Dom.XMLNode search = doc.getRootElement();
        for(Dom.XMLNode child: search.getChildElements()) {
            if(child.getName() == 'count') {
                output.searchResultCount = Integer.valueOf(child.getText());
            }
            if(child.getName() == 'result') {
                SearchResult newResult = new SearchResult();
                newResult.articleTitle = child.getChildElement('title', null).getText();
                newResult.articleUri = child.getChildElement('uri', null).getText();
                searchResults.add(newResult);
            }
        }

        //shorten full search uri
        // if(output.searchResultCount > 0) {
        //     fullSearchResultsUri = bitlyLink(fullSearchResultsUri);
        // }
        
        //shorten article uris
        for(Integer i = 0; i < searchResults.size(); i++) {
            searchResults[i].articleUri = bitlyLink(searchResults[i].articleUri);
        }

        //generate text result
        String resultText = 'I found ' + (searchResults.size() > 1 ? 'these' : 'this') + ' article' + (searchResults.size() > 1 ? 's' : '') + ' on our Success Center.';
        for(Integer i = 0; i < searchResults.size(); i++) {
            resultText += '\n\n' + (i + 1) + ') ' + searchResults[i].articleTitle + '\n' + searchResults[i].articleUri;
        }
        // resultText += '\n\nFull Search Results: ' + fullSearchResultsUri;
        output.searchResultText = resultText;

        //return results
        List<Output> returnWrapper = new List<Output>();
        returnWrapper.add(output);
        return returnWrapper;
    }

    public static String bitlyLink(string longUrl) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-ssl.bitly.com/v4/shorten');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer 8a054a50b5191c4c251546f6726fa940dd69c433');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody('{"long_url": "' + longUrl + '"}');
        HttpResponse res = http.send(req);
        Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped(res.getBody());
        return (String) root.get('link');
    }
}