trigger OpportunityLineItemEvents on OpportunityLineItem (before insert, before update,after insert, after update, before delete, after delete, after undelete ) {
    new OpportunityLineItemHelper().run();
}