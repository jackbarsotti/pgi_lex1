public with sharing class CustomCaseLookupController {
  
  public Case caseObj {get;set;} // new caseObj to create
  public List<Case> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  
  public CustomCaseLookupController() {
    caseObj = new Case();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksearch');
    runSearch();  
  }
   
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
  
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
  
  // run the search and return the records found. 
  private List<Case> performSearch(string searchString) {

    String soql = 'select id, CaseNumber from Case';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where CaseNumber LIKE \'%' + searchString +'%\'';
    soql = soql;
    System.debug(soql);
    return database.query(soql); 

  }
  
  // save the new caseObj record
  public PageReference saveCase() {
    insert caseObj;
    // reset the caseObj
    caseObj = new Case();
    return null;
  }
  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
    
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
 
}