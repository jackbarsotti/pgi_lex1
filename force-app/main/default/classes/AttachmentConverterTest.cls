@IsTest
public class AttachmentConverterTest {
    static testmethod void test1() {
        Account a=PGITestUtilities.createAccount(true);
		Attachment att = PGITestUtilities.createAttachment(a.Id);
        att.Name = 'QDV' + att.Name;
        insert att;
    }
}