public with sharing class GenLookupCntl {
    @AuraEnabled
    public static GenLookUpResult[] lookup(String searchString, String sObjectAPIName,
                                                           String fld_API_Text,String fld_API_Val, 
                                                           String fld_API_Search,  Integer limitVal, Boolean isSOQL, String filter
                                                           ) {
        
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        
        List<GenLookUpResult> results = new List<GenLookUpResult>();
        
                                                               
        try {
            fld_API_Val = fld_API_Val.trim();
            fld_API_Text = fld_API_Text.trim();
            if (!isSOQL) {
                String searchQuery = 'FIND \'*' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + ' (' + fld_API_Val + ',' + fld_API_Text + ') Limit ' + limitVal;
                System.debug('searchQuery = ' + searchQuery);         

                List<List<SObject>> searchList = search.query(searchQuery);
               // System.debug('searchList = ' + searchList);
               // System.debug('searchQuery = ' + searchQuery);
                
                for (SObject sObj : searchList[0]) {
                    Map<String, Object> fieldsToValue = sObj.getPopulatedFieldsAsMap();
                    System.debug('fieldsToValue :' + fieldsToValue);
                    if (fieldsToValue.containsKey(fld_API_Text) && fieldsToValue.containsKey (fld_API_Val)) {
                    	results.add(new GenLookUpResult((String)sObj.get(fld_API_Text), 
                                                                    (String) sObj.get (fld_API_Val)));    
                    }    
                }   
            } else {
                searchString='\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
                
                String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
                    ' FROM '+sanitizedSObjectAPIName+
                    ' WHERE '+fld_API_Search+' LIKE '+searchString+ 
                    ' LIMIT '+limitVal;
                System.debug('Query :' + query);
                
                for (SObject so : Database.query(query))
                {
                    results.add(new GenLookUpResult((String)so.get(fld_API_Text), (String)so.get (fld_API_Val)));
                }  
            }
            
        } catch (Exception e) {
            system.debug('Execption :' + e);
        }
        
        
        System.debug('results = ' + results);
        return results;
    }
}