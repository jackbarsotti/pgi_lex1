/********************************************************************************
Name:  PGIMasterContractLookupController()
Copyright © 2012  PGI
======================================================
======================================================
Purpose:
-------
This class used to search Tesla company and Contract name
======================================================
======================================================
History
-------
VERSION  AUTHOR                DATE        DETAIL              FEATURES/CSR/TTP
  1.0 – Capgemini India                                                  23/10/2012        Added 
********************************************************************************/  
public with sharing class PGIMasterContractLookupController 
{ 
   public string searchString{get;set;} 
  
   public string accountId{get; set;} 
   public string quoteType{get; set;}  
   public PGIMasterContractLookupController() {
     try{
        searchString = System.currentPageReference().getParameters().get('lksrch');
        accountId = System.currentPageReference().getParameters().get('accountId');
        quoteType = System.currentPageReference().getParameters().get('quoteType');
          
    } catch(Exception ex){
        system.debug('Test'+ex.getMessage());
    }  
  }
 
 public PageReference search() {
    try{        
            
    }catch (Exception ex){
            system.debug(LoggingLevel.ERROR,'Error When searching for Contract name '+ex.getMessage());
        }

    return null;
 }
 
  
  
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
 
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
  
  
 
}