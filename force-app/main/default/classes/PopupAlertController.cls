public with sharing class PopupAlertController
{
    public Boolean displayPopup {get;set;}
    public PopupAlertController (ApexPages.StandardController controller)
    {
  
    }
    public void showPopup()
    {
        displayPopup = true;
    }
    public void closePopup()
    {
         displayPopup = false;
    }
    public List<SelectOption> getItems()
    {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('US','US'));
    options.add(new SelectOption('CANADA','Canada'));
    options.add(new SelectOption('MEXICO','Mexico')); return options;
    }
    public PageReference redirectPopup()
    {
    displayPopup = false;
    //Please uncomment below 3 statements and replace YourObjectId
    PageReference p=new Pagereference('/');
    p.setRedirect(true);
    return p;
    }
}