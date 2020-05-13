public with sharing class Redirect {
 public PageReference fetchRecords() {
      PageReference p = new PageReference('/apex/SendCaseEmail');
       p.setRedirect(true);
     return p;
 }
}