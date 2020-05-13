/*
 * Controller for NewAccount VF Page
 */
public with sharing class NewAccount {
	
    public static final String READY_TALK_PROFILE = 'ReadyTalk';
    public String selectedRecordType;

    // constructor
    public NewAccount(ApexPages.StandardController controller) { 
        selectedRecordType = Apexpages.Currentpage().getParameters().get('RecordType');
    }
    // vf page load action
    public PageReference doInit() {
      if(!isReadyTalkProfile()) {
            PageReference pr = new PageReference('/001/e');
            pr.getParameters().put('nooverride', '1');
            if(selectedRecordType != null) {
                pr.getParameters().put('RecordType', selectedRecordType);
            }
            pr.setRedirect(true);
            return pr;
        } else {
            return null;
        }
    }
    // check if profile contains ReadyTalk
    public boolean isReadyTalkProfile() {        
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        
        if(profileName.contains(READY_TALK_PROFILE)) {
            return true;
        }
        else {
            return false;
        }
    }
}