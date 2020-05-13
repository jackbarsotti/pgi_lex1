public class MockDepartment {

    public String Status = 'New';
    public String Name = 'Mock Department Object';
    public String ParentAccount = MockAccount.getNewAccount().id;
    public Id OwnerId = MockUser.getNewUser().Id;

    
    public void setupDepartment(Department__c d) {
        d.Status__c = Status;
        d.Name = Name;
        d.Parent_Account__c = ParentAccount;
        d.OwnerId = OwnerId;
    }
       
    public static Department__c getNewDepartment() {
        Department__c d = new Department__c();
        MockDepartment md = new MockDepartment();
        md.setupDepartment(d);
        System.runAs(new User(Id = UserInfo.getUserId())){
          Database.insert(d);
        }
        return d;
    }
    
    public Department__c getDepartment() {
        Department__c d = new Department__c();
        setupDepartment(d);        
        Database.insert(d);        
        return d;
    }
}