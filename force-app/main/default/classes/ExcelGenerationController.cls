public without sharing class ExcelGenerationController{

    public string xmlheader {get;set;}
    
    public string endfile{get;set;}
    
    public List<string> listString{get;set;}
    
     
    
    public ExcelGenerationController() {
    
    
    xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
    
    endfile = '</Workbook>';
    
    listString = new List<string>();
    
    listString.add('1');
    
    listString.add('2');
    
    }
    
    }