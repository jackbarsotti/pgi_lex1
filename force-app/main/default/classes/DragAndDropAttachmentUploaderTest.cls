@isTest
private class DragAndDropAttachmentUploaderTest {
	static Account testAccount {get;set;}
	static Attachment file {get;set;}

	@isTest static void test_navigateToAttachment() {
		// setup test data
		Init();

		// start
		Test.startTest();

		// Setup the page and conroller
		PageReference pr = Page.DragAndDropAttachmentUploader;
        pr.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pr);
        DragAndDropAttachmentUploader controller = new DragAndDropAttachmentUploader();

        // assert attachment exists
        List<Attachment> files = controller.attachmentList;
        System.assertEquals(1, files.size());

        // assert sObject type label is properly displayed for "Account"
        String sObjectType = DragAndDropAttachmentUploader.getSobjectTypeFromKeyPrefix(String.valueOf(testAccount.Id));
        System.assertEquals(sObjectType, 'Account');

        // set selectedAttachmentId
        System.assertEquals(controller.selectedAttachmentId, null);
        controller.selectedAttachmentId = files[0].Id;
        System.assertNotEquals(controller.selectedAttachmentId, null);

        // perform navigateToAttachment() 
        controller.navigateToAttachment();

		// stop
		Test.stopTest();
	}

	@isTest static void test_uploadAttachmentNewFileNullFileId() {
		// setup test data
		Init();

		// start
		Test.startTest();

		// Setup the page and conroller
		PageReference pr = Page.DragAndDropAttachmentUploader;
        pr.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pr);
        DragAndDropAttachmentUploader controller = new DragAndDropAttachmentUploader();

        // assert attachment exists
        List<Attachment> files = controller.attachmentList;
        System.assertEquals(1, files.size());

        // perform upload with a null file id to create a new file
        String uploadStatus = DragAndDropAttachmentUploader.uploadAttachment(testAccount.Id, 'New File Body to add', 'testFile', null, true);
        System.assertEquals(uploadStatus.substring(0, 3), '00P');

		// stop
		Test.stopTest();
	}

	@isTest static void test_uploadAttachmentInProgress() {
		// setup test data
		Init();

		// start
		Test.startTest();

		// Setup the page and conroller
		PageReference pr = Page.DragAndDropAttachmentUploader;
        pr.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pr);
        DragAndDropAttachmentUploader controller = new DragAndDropAttachmentUploader();

        // assert attachment exists
        List<Attachment> files = controller.attachmentList;
        System.assertEquals(1, files.size());

        // perform upload adding content to an existing file and assert success file Id message is returned
        String uploadStatus = DragAndDropAttachmentUploader.uploadAttachment(testAccount.Id, 'More File Body to add', 'testFile', files[0].Id, true);
        System.assertEquals(uploadStatus, files[0].Id);

		// stop
		Test.stopTest();
	}

	@isTest static void test_uploadAttachmentNullBody() {
		// setup test data
		Init();

		// start
		Test.startTest();

		// Setup the page and conroller
		PageReference pr = Page.DragAndDropAttachmentUploader;
        pr.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pr);
        DragAndDropAttachmentUploader controller = new DragAndDropAttachmentUploader();

        // assert attachment exists
        List<Attachment> files = controller.attachmentList;
        System.assertEquals(1, files.size());

        // perform upload with null file body and assert error message is returned
        String uploadStatus = DragAndDropAttachmentUploader.uploadAttachment(testAccount.Id, null, 'testFile', files[0].Id, true);
        System.assertEquals(uploadStatus, 'Attachment Body Null');
        

		// stop
		Test.stopTest();
	}
	
	static void Init() {
    	testAccount = PGITestUtilities.createAccount(true);

    	// test attachment
        file = new Attachment();
        file.Name = 'testFile';
        Blob bodyBlob = Blob.valueOf('Test File Body');
        file.body = bodyBlob;
        file.parentid = testAccount.Id;
        insert file;
    }
}