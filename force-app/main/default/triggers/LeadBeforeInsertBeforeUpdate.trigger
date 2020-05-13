trigger LeadBeforeInsertBeforeUpdate on Lead (before insert, before update) {
  LeadActions.syncAddressFields(Trigger.new, Trigger.old);
  
  if(Trigger.isInsert) {
    LeadActions.setDefaultInvoiceTypes(Trigger.new);
  }

}