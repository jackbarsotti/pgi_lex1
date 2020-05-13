trigger OpportunityContactRoleTrigger on OpportunityContactRole (After insert, After update) {
    new OpportunityContactRoleTriggerHandler().run();
}