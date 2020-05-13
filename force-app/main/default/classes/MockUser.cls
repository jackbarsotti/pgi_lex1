public class MockUser {

  public String alias = 'testUser';
  public String email = 'qa@readytalk.com';
  public String emailencodingkey = 'UTF-8';
  public String lastname = 'Testing';
  public String languagelocalekey = 'en_US';
  public String localesidkey = 'en_US';
  public String profileid = ((Profile) Database.query('select id from profile where name=\'Standard User\'')).Id;
  public String timezonesidkey = 'America/Denver';
  public String username = 'qa@readytalk.com';
  public String EmployeeNumber='12345';  
    

  private void setupUser(User u) {
    u.alias = alias;
    u.email = email;
    u.emailencodingkey = emailencodingkey;
    u.lastname = lastname;
    u.languagelocalekey = languagelocalekey;
    u.localesidkey = localesidkey;
    u.EmployeeNumber=EmployeeNumber;  
    u.profileid = profileid;
    u.timezonesidkey = timezonesidkey;
    u.username = Test.isRunningTest()?username + 'unittest':username;
  }

  public static User getNewUser() {
    User u = new User();
    MockUser mu = new MockUser();
    mu.setupUser(u);
    try {
      System.runAs(new User(Id = UserInfo.getUserId())){
        Database.insert(u);
      }
    } catch (Exception e) {
      return (User) RTDataBaseUtils.getSObjectList(new User(), 'where username like \'qa@readytalk.com%\'').get(0);
    }
    //try {
    //  System.runAs(new User(Id = UserInfo.getUserId())){
    //    Database.insert(u);
    //  }
    //} catch (Exception e) {
    //  return (User) RTDataBaseUtils.getSObjectList(new User(), 'where username like \'sfdeveloper@readytalk.com%\'').get(0);
    //}
    return u;
  }

  public static User getSoapUser() {
    return (User) RTDataBaseUtils.getSObjectList(new User(), 'where username like \'test.user@pgi.com%\'').get(0);
  }

  public User getUser() {
    User u = new User();
    setupUser(u);
    try {
      System.runAs(new User(Id = UserInfo.getUserId())){
        Database.insert(u);
      }
    } catch (Exception e) {
      return (User) RTDataBaseUtils.getSObjectList(new User(), 'where username like \'test.user@pgi.com%\'').get(0);
    }
    return u;
  }
}