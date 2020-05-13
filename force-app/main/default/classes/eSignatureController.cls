public class eSignatureController {

	private final Opportunity opp;
	public ConMan_Contract__c ConManContract {get;set;}
	public enum eSignaturePage {IsContactInSFDC, UpdateContact, NewContact, AddAttachment, SendWithDocusign}
	public eSignaturePage currentPage {get;set;}
	public String Page {get{return currentPage.name();}}
	public Contact contact {
		get{
			if (contact == null){
				contact = new Contact();
				contact.AccountId = ConManContract.Account_Name__c;
				contact.Account = ConManContract.Account_Name__r;
			}
			return contact;
		}
		set;
	}
	public Attachment attachment {
		get{
			if (attachment == null)
				attachment = new Attachment();
			return attachment;
		}
		set;
	}
	public List<Attachment> attachments {
		get{
			if(attachments == null){
				if(opp.Attachments != null && opp.Attachments.size()>0){
					attachments = opp.Attachments;
				}
				else{
					attachments = [SELECT Id, Name, LastModifiedDate, Owner.Id, Owner.Name FROM Attachment WHERE ParentId =: conManContract.Id];
				}
			}
			return attachments;
		}
		set;
	}
	   
    public eSignatureController (ApexPages.StandardController controller){
        this.opp = (Opportunity) controller.getRecord();
        try{
        	List<ConMan_Contract__c> contracts = [SELECT Id, Account_Name__c, Account_Name__r.Name, Docusign_Customer_Signer__c, 
        		Docusign_Customer_Signer__r.Account.Name, Docusign_Customer_Signer__r.FirstName, Docusign_Customer_Signer__r.LastName, 
        		Docusign_Customer_Signer__r.Email, Docusign_Customer_Signer__r.Title, Docusign_Contract_Type__c
		        FROM ConMan_Contract__c WHERE Opportunity__c =: opp.Id AND RecordTypeId =: PGIAppConstants.EMEA_CONTRACT_RECORDTYPEID];
		        
		    if(contracts.size()>0){
	        	conManContract = contracts[0];
	    		conManContract.Account_Name__c = opp.AccountId;
	    	}
	    	else{
	    		conManContract = new ConMan_Contract__c();
	    		conManContract.RecordTypeId = PGIAppConstants.EMEA_CONTRACT_RECORDTYPEID;
	    		conManContract.Opportunity__c = opp.Id;
	    		conManContract.Account_Name__c = opp.AccountId;
			}
        }
        catch (Exception ex){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        currentPage = eSignaturePage.IsContactInSFDC;
    }
    
    public PageReference Yes(){
    	//contact is created before contact screen so that the docusign customer signer filter works 
    	if (conManContract.Id != null){
    		update conManContract;
    	}
    	else{
    		insert conManContract;
    	}
    	currentPage = eSignaturePage.UpdateContact;
     	return null;
    }
    
    public PageReference No(){
    	//contact is created before contact screen so that the docusign customer signer filter works 
    	if (conManContract.Id != null){
    		update conManContract;
    	}
    	else{
    		insert conManContract;
    	}
    	contact = null;
    	currentPage = eSignaturePage.NewContact;
     	return null;
    }
    
    public PageReference Cancel(){
     	PageReference pageRef = new PageReference('/' + opp.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference Back(){
    	currentPage = eSignaturePage.IsContactInSFDC;
     	return null;
    }
    
    public PageReference UpdateContact(){
    	try{
    		update conManContract;
    		contact = new Contact(Id = conManContract.Docusign_Customer_Signer__c);
    		contact.FirstName = conManContract.Docusign_Customer_Signer__r.FirstName;
    		contact.LastName = conManContract.Docusign_Customer_Signer__r.LastName;
    		contact.Email = conManContract.Docusign_Customer_Signer__r.Email;
    		contact.Title = conManContract.Docusign_Customer_Signer__r.Title;
    		update contact;
    		if(attachments.size()>0){
    			currentPage = eSignaturePage.SendWithDocusign;
    		}
    		else{
    			currentPage = eSignaturePage.AddAttachment;
    		}	
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
    	}
     	return null;
    }
    
    public PageReference SaveContact(){
    	try{
    		contact.AccountId = opp.AccountId;
    		insert contact;

    		conManContract.Docusign_Customer_Signer__c = contact.Id;
    		update conManContract;
    		conManContract.Docusign_Customer_Signer__r = contact;
    		
    		if(attachments.size()>0){
    			currentPage = eSignaturePage.SendWithDocusign;
    		}
    		else{
    			currentPage = eSignaturePage.AddAttachment;
    		}	
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
    	}
     	return null;
    }
    
    public void PopulateContact(){
    	try{
	    	List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Title, Account.Name FROM Contact WHERE Id =: conManContract.Docusign_Customer_Signer__c];
	    	if(contacts.size()>0){
	    		conManContract.Docusign_Customer_Signer__r = contacts[0];
	    	}
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
    	}
    }
    
    public PageReference Upload(){
    	try{
    		attachment.ParentId = conManContract.Id;
    		insert attachment;
    		attachments = [SELECT Id, Name, LastModifiedDate, Owner.Id, Owner.Name FROM Attachment WHERE ParentId =: conManContract.Id];
    		currentPage = eSignaturePage.SendWithDocusign;
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment'));
    	}
    	finally{
    		attachment = new Attachment();
    	}
    	return null;
    }
    
    public void UpdateConManContract(){
    	try{
    		update conManContract;
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
    	}
    }
}