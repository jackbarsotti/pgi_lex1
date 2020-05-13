public class MetadataRequestHandler {
    
    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    public static List<String> parseURI(String reqURI){
        List<String> valueList = reqURI.split('/');
        return valueList;
    }
    
    public static List<String> getURIElementAfter(String parentElement,String reqURI){
        boolean foundParent = false;
        List<String> uriElementsList = MetadataRequestHandler.parseURI(reqURI);
        List<String> elementList = new List<String>();
        for(String element : uriElementsList){
            if(element.equals(parentElement)){
                foundParent = true;
            }
            if(foundParent && !element.equals(parentElement))
                elementList.add(element);
        }
        foundParent = false;
        return elementList;
    }
    
    public static Map<String,String> retrieveRequest(String uri){
        List<String> uriReq = getURIElementAfter('MetadataEndPoint',uri);
        try{
            String packageName = uriReq.get(0);
            String [] packageMembers = new String[uriReq.size() - 1];
            for(Integer i = 1,j = 0; i < uriReq.size(); i++){
                packageMembers[j++] = uriReq.get(i);
            }
            if(packageName.equals('pollRequest')){
                String requestId = packageMembers[0];
                return pollRequest(requestId);
            }else{
               return requestMetadata(packageName,packageMembers);
            }
        }catch(Exception e){
            return new Map<String,String>{
                'error' => 'true',
                'message' => e.getMessage()
            };
        }
    }
    
    public static Map<String,String> requestMetadata(String packageName, String[] packageMembers){
        Map<String,String> message = new Map<String,String>();
        try{
            MetadataService.MetadataPort service = createService();				
            MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
            retrieveRequest.apiVersion = 29.0;
            retrieveRequest.packageNames = null;
            retrieveRequest.singlePackage = true;
            retrieveRequest.specificFiles = null;//new String[]{'Address.settings'};
            retrieveRequest.unpackaged = new MetadataService.Package_x();
            retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
            MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
            packageType.name = packageName; 
            packageType.members = packageMembers;
            retrieveRequest.unpackaged.types.add(packageType);
            MetadataService.AsyncResult asyncResult = service.retrieve(retrieveRequest);
            message.put('asyncResultID',asyncResult.id);
        }catch(Exception e){
            message.put('error',e.getMessage());
        }
        
        return message;
    }
    
    public static Map<String,String> pollRequest(String requestId){
        Map<String,String> message = new Map<String,String>();
        MetadataService.MetadataPort service = createService();
        MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(requestId,true);
        message.put('status',retrieveResult.status);
        if(retrieveResult.done){
            if(retrieveResult.status.equals('Succeeded')){
                message.put('zipFile',retrieveResult.zipFile);
            }
        }
        return message;
    }                                       
}