@isTest(SeeAllData=true)
public class CaseTriggerHandler_Test {
    
    static testmethod void myTestMethod1() {
        
        List<Case> caseLst =[SELECT Id,ParentId,SuppliedEmail,Subject,Status 
                             FROM Case 
                             WHERE SuppliedEmail !=null 
                             AND Subject !=null 
                             AND Status = 'Closed' AND ClosedDate >: System.now().addDays(-1) LIMIT 5];
        if(caseLst.size() > 0){
            Set<Id> caseIdSet = new  Set<Id>();
            List<Case> caseToUpdate = new List<Case>();
            for(Case obj :caseLst){
                System.debug('The Id'+obj.id);
                caseIdSet.add(obj.Id);
                case objCase = obj.clone();
                objCase.Status='In Progress';
                caseToUpdate.add(objCase);  
            }
            INSERT caseToUpdate;
            // for(Case objCase :[Select Id,Status from Case Where Id=:caseIdSet]){
            //     System.assertEquals('Customer Replied', objCase.Status);
            // }
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseToUpdate[0].Id;
            objEmailMsg.Subject = caseToUpdate[0].subject;
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'noreply@pgi.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            
            insert objEmailMsg;
        } 
    }
    
}