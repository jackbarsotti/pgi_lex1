@isTest
public class CreateRFCImpactControllerTest {
	//@isTest
 //   public static void testPageInitMethods() {
 //   	Request_For_Change__c testRFCRelatedSCA = PGITestUtilities.createRFC(false);
 //       testRFCRelatedSCA.Status__c = 'Approved';
 //       testRFCRelatedSCA.RecordTypeId = PGITestUtilities.RFCStandardRT;
 //       insert testRFCRelatedSCA;
        
 //       Request_For_Change__c testRecord = PGITestUtilities.createRFC(false);
 //       testRecord.Related_SCA__c = testRFCRelatedSCA.Id;
 //       insert testRecord;

 //       RFC_Risk_Assessment__c testRiskAssessment = new RFC_Risk_Assessment__c(Request_For_Change__c = testRecord.Id);
 //       insert testRiskAssessment;
 //       RFCImpact__c testRFCImpact = new RFCImpact__c(RequestForChange__c = testRecord.Id);
 //       insert testRFCImpact;

 //       Test.startTest();

 //    	PageReference pageRef = Page.CreateRequestForChangeImpact;
 //       Test.setCurrentPage(pageRef);
 //    	ApexPages.StandardController sc = new ApexPages.StandardController(testRFCImpact);
 //    	CreateRequestForChangeImpactController controller = new CreateRequestForChangeImpactController(sc);
 //       List<LayoutDescriberHelper.LayoutSection> testLayoutSectionsGetSet = controller.layoutSections;
 //       List<LayoutDescriberHelper.AssignmentModel> testAssignmentSectionsGetSet = controller.assignmentSections;
 //       System.assert(controller.saveAndNext() != null);

 //       Test.stopTest();
 //   }
}