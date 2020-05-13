public class ESB_Interface {
    
    /* Exception to throw when endpoints fail */
    public class EndpointException extends Exception {}
    /* Exception to throw when endpoints return unexpected data */
    public class ParsingException extends Exception {}

    public static String formatException(Exception e) {
        return e.getTypeName() + ' (Line ' + e.getLineNumber() + ')' + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
    }
    
    /* Configure the HTTP Request for ESB calls */
    public static HttpRequest httpESB(String endpoint) {
        iContract_Custom_Settings__c settings = iContract_Custom_Settings__c.getInstance();
        HttpRequest request = new HttpRequest();
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(settings.Mulesoft_Username__c + ':' + settings.Mulesoft_Password__c));
        request.setHeader('Authorization', authorizationHeader);
        request.setEndpoint(settings.Mulesoft_Server__c + '/' + endpoint);
        return request;
    }
    
}