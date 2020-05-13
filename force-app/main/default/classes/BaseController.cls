public with sharing abstract class BaseController{

  protected PageReference goBack() {
    //Redirect back to retURL
    PageReference redir = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));     
    return redir.setRedirect(true);        
  }    

  protected virtual PageReference gotoView(String id) {
    PageReference redir = new PageReference('/' + id);                  
    return redir.setRedirect(true); 
  }

  protected virtual PageReference gotoView(SObject o) {
    return new ApexPages.StandardController(o).view();
  }

  protected virtual PageReference gotoView(SObject o, Map<String, String> params) {
    PageReference redir = new ApexPages.StandardController(o).view();
    redir.getParameters().putAll(params);
    return redir.setRedirect(true);
  }

  protected virtual String getPageID() {
    return ApexPages.currentPage().getParameters().get('id');
  }

  protected virtual String getRetURL() {
    if(ApexPages.currentPage().getParameters().get('retURL') != null)
      return ApexPages.currentPage().getParameters().get('retURL').replace('/','').left(15);
    else
      return '';
  }

  protected virtual PageReference gotoEdit(SObject o) {
    return gotoEdit(o, new Map<String, String>());
  }    

  protected virtual PageReference gotoEdit(SObject o, Map<String, String> params) {
    PageReference redir = new ApexPages.StandardController(o).edit();
    redir.getParameters().putAll(params);
    return redir.setRedirect(true);
  }

  public virtual PageReference cancel() {
    return goBack();
  }

  public virtual boolean getIsAdministrator() {
    return RTDatabaseUtils.isAdministrator();
  }
}