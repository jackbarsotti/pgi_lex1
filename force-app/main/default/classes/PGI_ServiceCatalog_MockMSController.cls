/*
    Name:-- PGI_ServiceCatalog_MockMSController
    Description:-- This Mock class is used to create fake reponse from Test class.
*/
global class PGI_ServiceCatalog_MockMSController implements HttpCalloutMock{
	global HttpResponse respond(HTTPRequest req){
		String requ = String.ValueOF(req);
		HttpResponse res; 
		if(requ == 'System.HttpRequest[Endpoint=https://login.microsoftonline.com/common/oauth2/v2.0/token, Method=POST]'){
			res = new HttpResponse();
		    res.setStatus('OK');
		    res.setStatusCode(200);
		    res.setBody('{"token_type":"Bearer","scope":"User.Read Mail.Read","expires_in":3600,"ext_expires_in":0,"access_token":"EwA4A8l6BADlZKaCUQkOgI=","refresh_token":"MCdK7s5vVII2xrI8AoYAydjugpm9_eLEDvrg"}');
		     
		}else if(requ == 'System.HttpRequest[Endpoint=https://graph.microsoft.com/v1.0/me, Method=GET]'){
			res = new HttpResponse();
		    res.setStatus('OK');
		    res.setStatusCode(200);
		    res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","givenName":"bars","surname":"bars","displayName":"bars","id":"5caaf377fa1942b6","userPrincipalName":"timbarsotti@gmail.com","businessPhones":[],"jobTitle":null,"mail":null,"mobilePhone":null,"officeLocation":null,"preferredLanguage":null}');
			
		}
		return res;
  	}
}