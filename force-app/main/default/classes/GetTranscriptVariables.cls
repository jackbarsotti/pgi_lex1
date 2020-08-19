public with sharing class GetTranscriptVariables {

  public class Input {
    @InvocableVariable(required=true)
    public Id routableID;
  }

  public class Output {
    @InvocableVariable(required=false)
    public String firstName;

    @InvocableVariable(required=false)
    public String deploymentName;
  }

  @InvocableMethod(label='Get Chat User Details')
  public static List<Output> getUserName(List<Input> inputs) {

    Input input = inputs[0];
    Output output = new Output();
    Id deploymentId;
    
    try {
        LiveChatTranscript transcriptRecord = [SELECT Id, First_Name__c, Last_Name__c, Name__c, LiveChatDeploymentId FROM LiveChatTranscript WHERE Id = :input.routableID];
        transcriptRecord.Name__c = transcriptRecord.First_Name__c + ' ' + transcriptRecord.Last_Name__c;
        UPDATE transcriptRecord;

        output.firstName = transcriptRecord.First_Name__c;
        deploymentId = transcriptRecord.LiveChatDeploymentId;
    }
    catch (Exception e) {
        output.firstName = 'Annonymous';
        deploymentId = null;
    }

    try {
      LiveChatDeployment deployment = [SELECT DeveloperName FROM LiveChatDeployment WHERE Id = :deploymentId];
      output.deploymentName = deployment.DeveloperName;
    }
    catch (Exception e) {
      output.deploymentName = 'Unknown';
    }
                                             
    List<Output> returnWrapper = new List<Output>();
    returnWrapper.add(output);
    
    return returnWrapper;
  }
}