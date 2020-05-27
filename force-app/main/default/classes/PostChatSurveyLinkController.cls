public class PostChatSurveyLinkController {
    
    public PageReference createSurveyLink() {
    
    String myChatKey = apexpages.currentpage().getparameters().get('chatKey');
    String surveyId = apexpages.currentpage().getparameters().get('surveyId');
    
            List<LiveChatTranscript> lct = new List<LiveChatTranscript>();
            lct = [Select Id from LiveChatTranscript WHERE LiveChatTranscript.ChatKey = : myChatKey LIMIT 1];   
    
            try {
                PageReference surveyURL = new PageReference('/TakeSurvey?id=' + surveyId + '&cId=none&caId=none&ctId=' + lct[0].Id);
                surveyURL.setRedirect(true);
                return surveyURL;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
    }
}