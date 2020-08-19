public with sharing class accountrecordsat {

@AuraEnabled(cacheable=true)
public static string getAccountDetails(string accid){

string name =([SELECT Id, Name from Account where Id =:accid]).Name;

system.debug(name);

return name;
}

@AuraEnabled
public static Opportunity createopp(string accidt,string oppname){
system.debug(accidt);
system.debug(oppname);
Opportunity newOpp = new Opportunity();
newOpp.AccountId = accidt;
newOpp.CloseDate = System.today() + 90;
newOpp.StageName = 'Legal';
newOpp.Name = oppname;
INSERT newOpp;

system.debug('hi'+newOpp.Id);

string oppid = newOpp.Id;
system.debug('hi'+oppid);
system.debug(newOpp);

return newOpp;

}

// @AuraEnabled(cacheable=true)
// public static Map<string,string> getExperiments(){

//     Map <string,string> experimentdetails = new Map<string,string>();

//   for(Experiment__c obj :[SELECT Id, Name 
//                          FROM Experiment__c
//                          WHERE Name LIKE '%live%']){
                         
//      experimentdetails.put(obj.Id,obj.Name);
//                          }
    
// system.debug(experimentdetails);
// return experimentdetails ;
// }



}