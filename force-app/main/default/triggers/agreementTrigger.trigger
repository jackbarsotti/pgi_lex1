/* TriggerName : agreementTrigger
* CreatedOn : 12/Jul/2019
* LastModifiedOn : 12/Jul/2019
* CreatededBy : Vijay
* ModifiedBy : Anup
* Description : When the agreement is created or Modified then this trigger will be fired to populate fields in Opportunity 
                and PGI-Contract
*/
trigger agreementTrigger on echosign_dev1__SIGN_Agreement__c (before insert, before update, after insert, after update) {
    new agreementTriggerHandler().run();
}