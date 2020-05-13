trigger PGiContractTrigger on CONMAN_Contract__c (before update, after update, before insert) {
    new PGiContractTriggerHandler().run();
    if(Trigger.isBefore && Trigger.isInsert) {
        //new PGiContractTriggerHandler().run();
    }
    else {
        // PGi Contracts that are Deal Desk Approved and will have their floors updated
        Map<Id, CONMAN_Contract__c> agreementsWithNewFloors = new Map<Id, CONMAN_Contract__c>();
        
        // PGi Contracts that need emails sent to the ARG Contact
        Map<Id, CONMAN_Contract__c> agreementsThatNeedEmailsSent = new Map<Id, CONMAN_Contract__c>();

        // Check all Triggered PGi Contracts
        for (Id ctrcId : Trigger.newMap.keySet()) {

            if (Trigger.isBefore && Trigger.isUpdate) {
                // PGi Contracts that are Deal Desk Approved and will have their floors updated
                if (Trigger.newMap.get(ctrcId).Deal_Desk_Approved__c == true && Trigger.oldMap.get(ctrcId).Deal_Desk_Approved__c == false) {
                    // Reset this flag back to normal later
                    Trigger.newMap.get(ctrcId).Deal_Desk_Approved__c = false;
                    agreementsWithNewFloors.put(ctrcId, Trigger.newMap.get(ctrcId));
                }
            }
            
            /* DISABLED if (Trigger.isAfter && Trigger.isUpdate) {
                // PGi Contracts that are Approved or Rejected will send out an email to the contact
                if ((Trigger.newMap.get(ctrcId).Contract_Status__c == 'Approved' && Trigger.oldMap.get(ctrcId).Contract_Status__c != 'Approved') || (Trigger.newMap.get(ctrcId).Contract_Status__c == 'Rejected' && Trigger.oldMap.get(ctrcId).Contract_Status__c != 'Rejected')) {
                    if(Trigger.newMap.get(ctrcId).Owner_Type__c == 'ARG Partner Connect') {
                        agreementsThatNeedEmailsSent.put(ctrcId, Trigger.newMap.get(ctrcId));
                    }
                }
            }*/
        }

        // Try to update floors for Deal Desk Approved PGi Contracts
        try {
            if (agreementsWithNewFloors != null && !agreementsWithNewFloors.isEmpty())
                iContract.dealDeskUpdatedFloors(agreementsWithNewFloors.keySet());
        } catch (Exception e) {
            System.debug('Exception when updating Deal Desk floors');
            System.debug(e.getStackTraceString());
        }

        // Try to send emails for ARG Approved/Rejected PGi Contracts
        /* DISABLED try {
            if (agreementsThatNeedEmailsSent != null && !agreementsThatNeedEmailsSent.isEmpty())
                iContract.sendARGApprovalCompletedEmails(agreementsThatNeedEmailsSent.keySet());
        } catch (Exception e) {
            System.debug('Exception when sending ARG floors');
            String test = e.getMessage();
            System.debug(e.getStackTraceString());
        }*/
    }
}