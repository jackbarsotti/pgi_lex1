public with sharing class ToDelete {
    private ApexPages.StandardSetController controller;
 public ToDelete(ApexPages.StandardSetController controller) {
     this.controller = controller;
     Set<Id> selectedIds = new Map<Id, SObject>(controller.getSelected()).keySet();
     System.debug('The Valueis'+selectedIds);
    }
}