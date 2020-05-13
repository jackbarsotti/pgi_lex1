public with sharing class JIRA {

  // Change values in this class according to you JIRA/Salesforce coordinates.

  public static String baseUrl = 'https://jira.ecovate.com'; // Base URL of your JIRA instance
  public static String systemId = '1'; // Salesforce Connector System ID in JIRA
  public static String username = 'salesforce';  // JIRA username
  public static String password = 'ecovate07'; // JIRA password

  public static String agentProfileName = 'System Admin API Only'; // Jira agent profile name in Salesforce

  // Constructs Basic Http Authentication header from provided credentials
  public static String authHeader(String u, String p) {
    Blob headerValue = Blob.valueOf(u + ':' + p);
    return 'Basic ' + EncodingUtil.base64Encode(headerValue);
  }

  // Sends a request and returns the response
  public static HttpResponse sendRequest(HttpRequest req) {
    Http http = new Http();
    HttpResponse resp = http.send(req);
    system.debug(resp.getBody());
    system.debug(resp.getStatus());
      system.debug(resp.getStatusCode());
      
    return http.send(req);
  }

  // Detects whether current user is not JIRA agent. By calling this you can make sure that
  // infinite loops won't happen in triggers (for instance when synchronizing an issue with JIRA)
  public static Boolean currentUserIsNotJiraAgent() {
    Boolean allow = false;
    List<Profile> jiraAgentProfile = [SELECT Id FROM Profile WHERE Name = :JIRA.agentProfileName];
    if (!jiraAgentProfile.isEmpty()) {
      String jiraProfileAgentId = String.valueOf(jiraAgentProfile[0].id);
      allow = UserInfo.getProfileId() != jiraProfileAgentId;
    }
    return allow || Test.isRunningTest();
  }
}