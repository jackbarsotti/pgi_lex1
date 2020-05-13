public class CaseEmailRelatedListController {
    public case Objcase{get;set;} 
    public Id caseId{get;set;}
    public List<EmailMessage>  emailMsgLst{get;set;}
    public Boolean isOutOrInBoundRt{get;set;}
    public CaseEmailRelatedListController(ApexPages.StandardController controller) {
        List<String> isOutOrInBoundRtLst= new List<String>{'Outbound_Email_Support','Inbound_Email_Support'};
        Map<Id,RecordType> idByRecordTypeMap=new Map<Id,RecordType>([SELECT ID,DeveloperName from RecordType WHERE DeveloperName=:isOutOrInBoundRtLst]);
        System.debug('>>>idByRecordTypeMap>>>'+idByRecordTypeMap);
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Id inboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inbound_Email_Support').getRecordTypeId();
        this.Objcase =(Case)controller.getRecord();  
        Objcase.Id= ApexPages.currentPage().getParameters().get('id');
        System.debug('>>>>>>'+Objcase.RecordTypeId);
        isOutOrInBoundRt = idByRecordTypeMap.containsKey(Objcase.RecordTypeId);
        System.debug('>>>isOutOrInBoundRt>>>'+isOutOrInBoundRt);
        emailMsgLst = new List<EmailMessage>();
        //RT- 474 Custom Email Related List should hide emails from System
        Set<Id> allUserIdSet = new Set<Id>();
        for(EmailMessage emailobj : [SELECT CreatedById 
                                            FROM EmailMessage 
                                            WHERE ParentId =:Objcase.Id]){
            allUserIdSet.add(emailobj.CreatedById);
        }
        //To store only the user who are not System user.
        Set<Id> notSystemUserId = new Set<Id>();
        for(User objUser : [SELECT Id 
                                FROM User 
                                WHERE Name != 'System' AND Id=:allUserIdSet]){
            notSystemUserId.add(objUser.Id);
        }

        //  jhegarty 2020-04-14 added ", TextBody, HtmlBody" to select query 
        emailMsgLst = [SELECT Id, ParentId, Status, ToAddress , HasAttachment , CreatedDate,MessageDate, Subject, FromName, FromAddress, TextBody, HtmlBody 
                    FROM EmailMessage 
                    WHERE ParentId =:Objcase.Id 
                        AND ((CreatedById =:notSystemUserId AND Incoming = false) 
                            OR Incoming = true) 
                        AND (NOT Subject_Indexed__c LIKE 'Automatic Reply%') 
                        ORDER BY MessageDate DESC];
    }
    public PageReference sendMail()
    {
        PageReference p = new PageReference('/apex/SendAnEmail?id='+Objcase.Id);
        p.setRedirect(true);
        return p;
    }
    public PageReference sendTolightning() {
        System.debug('The Email'+emailMsgLst);
        String mailId = ApexPages.currentPage().getParameters().get('mailId');
        String toAll = ApexPages.currentPage().getParameters().get('toAll');
        System.debug('The IDSS'+mailId);
        PageReference p = new PageReference('/apex/SendAnEmail');
        // p.getParameters().put('email', emailMsgLst);
        p.getParameters().put('id', ObjCase.Id);
        p.getParameters().put('mailId', mailId);
        p.getParameters().put('toAll', toAll);
        p.getParameters().put('replay', 'true');
        p.setRedirect(true);
        return p;

    }
    public PageReference deleteEmail()
    {
        Id emailId = Apexpages.currentPage().getParameters().get('mailId');
        Delete [SELECT Id FROM EmailMessage where Id=:emailId];
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference redirectPage = new PageReference(baseUrl+'/'+Objcase.id); 
        return redirectPage; 
    }
    public PageReference redirectToEmailMessage()
    {
        Id emailId = Apexpages.currentPage().getParameters().get('mailId');
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference redirectPage = new PageReference(baseUrl+'/'+emailId); 
        return redirectPage; 
    }
}