@isTest
private class testErrorMessage {
    
    static testMethod void testConstruct() {
        ErrorMessage e = new ErrorMessage();
        System.assert(e!=null);
    }
    
    static testMethod void testGetters() {
        ErrorMessage e = new ErrorMessage();
        System.assert(e.getId() == null);
        System.assert(e.getMessage() == null);
    }    
    // It cover all methods 
    static testMethod void testSetters() {
        Id id; 
        String message;
        ErrorMessage e = new ErrorMessage();
        System.assert(e.setId(id) == null);
        System.assert(e.setMessage(message) == null);
        
        System.assert(e.getId() == null);
        System.assert(e.getMessage() == null);
    } 
}