@RestResource(urlMapping='/MetadataEndPoint/*')
global with sharing class MetadataEndPoint {
    @HttpGet
    global static String getMetadata() {
        Map<String,String> message = new Map<String,String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        message = MetadataRequestHandler.retrieveRequest(req.requestURI);
        return json.serialize(message);
    }

}