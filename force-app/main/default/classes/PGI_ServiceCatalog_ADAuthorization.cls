/*
    Name:-- 
    Created Date:-- 14-June-2017
    Description:-- This apex class is used to authenticate with MS.
*/

public class PGI_ServiceCatalog_ADAuthorization {
	 
    public String code{get;set;}  
    External_App_Settings__c eas = External_App_Settings__c.getValues('PGi_AD');
    
    private String key = ''; //'24d4eb8e-83d3-4f59-9c34-bee10289b1ac';
    private String secret = ''; //'WSca2SV0mTnHy6nKBNqcerP';
    private String redirect_uri = '';
    private String accessToken;
    
    public String givenName{get;set;} 
    public String surname{get;set;}
    public String displayName{get;set;} 
    public String MicrosoftId{get;set;}
    public String userPrincipalName{get;set {
        userprincipalname = value;
        controller.ADUser = userPrincipalName;
    }} 
 
    public boolean isGetAuth{get;set;}
    
    public String refreshToken;
    
    public Boolean isCookieSet{get;set;}
    private PGI_ServiceCatalogController controller {get; set;}
    public PGI_ServiceCatalog_ADAuthorization(PGI_ServiceCatalogController c){
        if(eas != null) {
            secret = eas.App_Secret__c;
            key = eas.App_Key__c;
        }
 		this.controller = c;
        isCookieSet = false;
        isGetAuth = false;
 
        givenname=''; 
        surname='';
        displayname=''; 
        microsoftId='';
        userprincipalname=''; 

        code = ApexPages.currentPage().getParameters().get('code');
        redirect_uri = controller.baseUrl;

        //Get refresh token from Cookie
        Cookie counter = ApexPages.currentPage().getCookies().get('refreshToken');
        if(counter != null){
        	//Getting Access token from refresh token.
        	String at = createAccessTokenFromRefreshToken(String.ValueOf(counter.getValue()));
        }
        
        //Execute only Onces after redirect back
        if(code != null){
        	//We got code from the url and valid only 1 time 
            accessToken();
        }
    }
    public PageReference checkUser() {
        if(!controller.internalUser) {
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The PGi Service Catalog is only accessible from within Salesforce now.  Please login to Salesforce to access the Service Catalog and submit requests as needed.'));
            // if(isGetAuth){
            //     return null;
            // } else {
            //     return authMS();
            // }
        }
        return null;
    }
    //Login Method to Redirect to MS website
    public PageReference authMS(){
        if(code == null){
            if(key !='' && redirect_uri != ''){       
                PageReference pg = new PageReference(MSAuthUri(key, redirect_uri)) ;
                return pg;  
            }
        } else {
        	//If code is not empty
            accessToken();
            if(userPrincipalName == null || !userPrincipalName.contains('@pgi.com')) {
                accessToken = null;
                refreshToken = null;
                isGetAuth = false;
                code = null;
                logout();
                PageReference pg = new PageReference(MSAuthUri(key, redirect_uri)) ;
                return pg;  
            }
        }
        return null;
    }
    
    //Method Which redirect current page to MS webite for authenication
    //And This method is create url 
    private String MSAuthUri(String Clientkey,String redirect_uri){
        String key = EncodingUtil.urlEncode(Clientkey,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String state = String.valueOf(Math.abs(Math.random()));
        String authuri = '';
        authuri = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?'+
        'client_id='+key+
        '&response_type=code'+
        '&redirect_uri='+uri+
        '&response_mode=query'+
        '&scope=offline_access%20openid%20user.read'+
        '&state=12314';
         
        return authuri;
    }
    
    //Getting access token from code.
    private void accessToken(){
    	//MS application password
        
        //set message body for callouts
        String messageBody = 'code='+code+'&client_id='+key+'&client_secret='+secret+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';
        
        //Getting correct response from  sendHttp(messageBody)

        String resp = sendHttp(messageBody);
        if(resp !=''){
            JSONParser parser = JSON.createParser(resp);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'access_token'){
                        accessToken = parser.getText();
                    }else if(fieldName == 'refresh_token'){
                    	refreshToken = parser.getText();
                    }
                }
            }
            // After getting access token Now make call fro user basic information
            if(accessToken != ''){
                getCurrentUserInfo();
            }
        }

    }
    //This method is used to callout Access token 
    private String sendHttp(String msgBody){
    	
    	String messageBody = msgBody;
       
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        HttpResponse res;
        Http h = new Http();
        String resp;
        if(Test.isRunningTest()) {
            PGI_ServiceCatalog_MockMSController mock = new PGI_ServiceCatalog_MockMSController();
            res = mock.respond(req);
        } else {
            res = h.send(req);
        }
        resp = res.getBody();
        
        if(res.getStatuscode()==200){
            return resp;
        }else{
        	//If getting error from callouts then pass empty String to accessToken() method; 
            return '';
        }
    }
    
    //This method is used to get information about current login user from MS
    private void getCurrentUserInfo(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://graph.microsoft.com/v1.0/me');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        req.setTimeout(60000);

        Http h = new Http();
        String resp;
        if(!Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            resp = res.getBody();
            if(res.getStatusCode()==200){
                Map<String, Object> mm = (Map<String, Object>)JSON.deserializeUntyped(resp);
                userprincipalname= mm.get('userPrincipalName')!=null ? String.ValueOf(mm.get('userPrincipalName')):'';  
                if(userprincipalname.contains('@pgi.com')) {
                    isGetAuth = true;
                    givenname= mm.get('givenName')!=null ?String.ValueOf(mm.get('givenName')):''; 
                    surname= mm.get('surname')!=null ?String.ValueOf(mm.get('surname')):''; 
                    displayname=  mm.get('displayName') !=null ?String.ValueOf(mm.get('displayName')):''; 
                    microsoftId= mm.get('id')!=null ?String.ValueOf(mm.get('id')):''; 
                    //After successfully Set cookie
                    if(isCookieSet == false){
                    	setCookieController();
                    }
                } 
            } 
        }
    }
    
    //This method is used to set cookie
    public void setCookieController() {
    	isCookieSet = true;
    	Cookie counter = ApexPages.currentPage().getCookies().get('refreshToken');
    	if(counter == null) {
    		counter = new Cookie('refreshToken',refreshToken,null,-1,false);
    	}
    	ApexPages.currentPage().setCookies(new Cookie[]{counter});
    }
    
    //This method is used to get information about current login user from MS
    private String createAccessTokenFromRefreshToken(String refreshToken){
        String messageBody = 'client_id='+key+'&scope=offline_access%20openid%20user.read&refresh_token='+refreshToken+'&redirect_uri='+redirect_uri+'&grant_type=refresh_token&client_secret='+secret;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        Http h = new Http();
        String resp;
        if(!Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            resp = res.getBody();
            integer code =res.getStatuscode();
            if(code == 200){
            	Map<String, Object> mm = (Map<String, Object>)JSON.deserializeUntyped(resp);
            	accessToken= mm.get('access_token')!=null ? String.ValueOf(mm.get('access_token')):''; 
            	getCurrentUSerInfo();
            }
        }
        
    	return null;
    }
    
    //Logout button which delete the cookie
    public PageReference logout() {
    	isCookieSet = false;
    	Cookie counter = ApexPages.currentPage().getCookies().get('refreshToken');
    	counter = new Cookie('refreshToken',refreshToken,null,0,false);
    	ApexPages.currentPage().setCookies(new Cookie[]{counter});
    	
    	return new PageReference('/').setRedirect(true);
    }
}