/**
 * A dispatcher class to redirect control to a custom controller.  By default, all parameters are forwarded to the new page.
 */
public with sharing class Dispatcher {

    String objectName;
    Map<String, String> objectToControllerMapping;
    PageReference currentPage = ApexPages.currentPage();
    Map<String, String> additionalPageParameters;
    
    /**
     * Constructor for Standard Set Controllers
     */
    public Dispatcher(ApexPages.StandardSetController controller) {
        this.objectToControllerMapping = RTConfig.OBJECT_TO_CONTROLLER_MAPPING;
        this.objectName = controller.getRecord().getSObjectType().getDescribe().getName();
    }

    /**
     * Constructor for Standard Controllers
     */
    public Dispatcher(ApexPages.StandardController controller) {
        this.objectToControllerMapping = RTConfig.OBJECT_TO_CONTROLLER_MAPPING;
        this.objectName = controller.getRecord().getSObjectType().getDescribe().getName();
    }   
    
    public Dispatcher(Map<String, String> objectToControllerMapping) {
        this.objectToControllerMapping = objectToControllerMapping; 
    }
    
    public PageReference dispatch() { 
        String themeType = UserInfo.getUITheme();
        System.debug('>>themeType'+themeType);
        if(themeType=='Theme3'){
            
        PageReference redir = null;
        
        try{
            redir = new PageReference(this.objectToControllerMapping.get(getObjectName()));
            redir.getParameters().putAll(getCurrentPage().getParameters());
            redir.getParameters().putAll(getAdditionalPageParameters());
            redir.setRedirect(true); 
        }
        catch (Exception e){
            ApexPages.addMessages(e);  
        }
            
        return redir;  
      }
        else{
            
            return null;
        }
    }
    
    public String getObjectName(){
        return this.objectName;
    }    
    
    public void setObjectToControllerMapping(Map<String, String> objectToControllerMapping) {
        this.objectToControllerMapping = objectToControllerMapping;
    }
    
    public void setCurrentPage(PageReference currentPage) {
        this.currentPage = currentPage;
    }
    
    public PageReference getCurrentPage() {
        return this.currentPage;
    }
    
    public void setAdditionalPageParameters(Map<String, String> params) {
        this.additionalPageParameters = params;
    }
    
    public Map<String, String> getAdditionalPageParameters() {
        return this.additionalPageParameters;
    }
}