@isTest
public class PostChatSurveyLinkControllerTest {

  static  testMethod void test1(){
       Test.startTest();

       LiveChatVisitor lcv = new LiveChatVisitor();
       INSERT lcv;
        
       LiveChatTranscript ctRecord = new LiveChatTranscript(LiveChatVisitorId = lcv.Id,
                                         Email_Address__c='test@pgi.com',
                                         Subject__c='Test'
                                     );
       INSERT ctRecord;
        
       PageReference ref = new PageReference('/apex/PostChatSurveyLinkGenerator'); 
       ref.getParameters().put('id', String.valueOf(ctRecord.Id));
       Test.setCurrentPage(ref);
            
       PostChatSurveyLinkController con = new PostChatSurveyLinkController();               
       con.createSurveyLink();
                
       Test.StopTest();
     }
     
  static  testMethod void test2(){  
       //invalid chat transcript Id test
       Test.startTest();
       PageReference ref = new PageReference('/apex/PostChatSurveyLinkGenerator'); 
       ref.getParameters().put('id', 'invalid');
       Test.setCurrentPage(ref);
       
      try
      {
           PostChatSurveyLinkController con = new PostChatSurveyLinkController();               
           con.createSurveyLink();
       }
       Catch(exception e)
       {
       
       }
                            
       Test.StopTest();    
   }

}