/********************************************************************************
Name:  PGIContractProductDetails()
Copyright © 2013  PGI
======================================================
======================================================
Purpose:
-------
Wrapper class to store the product and verbiage details
======================================================
======================================================
History
-------
VERSION  AUTHOR                DATE        DETAIL              FEATURES/CSR/TTP
  1.0 – Capgemini India          02/01/2013        Added 
**********************************************************************************************/  
public class PGIContractProductDetails{
    
    public class Verbiage{
        public string prodName {get ;set;}
        public string termsConditions {get;set;}
        public string productId{get;set;}
        public string verbiageId{get;set;}
        public string ContractDocumentGroup{get;set;}
        public string VerbName{get;set;}
        public boolean IsServiceProduct{get;set;}
        public string producttype {get;set;}
        
        public Verbiage(){

        }
    }
 }