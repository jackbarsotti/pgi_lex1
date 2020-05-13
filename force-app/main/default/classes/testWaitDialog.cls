@isTest
private class testWaitDialog {
    
    static testMethod void testConstruct() {
        WaitDialog w = new WaitDialog();
        System.assert(w!=null);
    }
    
    static testMethod void testGetters() {
        WaitDialog w = new WaitDialog();
        System.assert(w.getHeader() != null);
        System.assert(w.getStatus() != null);
        System.assert(w.getButton() != null);
        System.assert(w.getCancelButton() != null);
        System.assert(w.getAdditionalInfo() != null);
        System.assert(w.getShouldRender() != null);
        System.assert(w.getShouldRenderCancelButton() != null);
        System.assert(w.getShouldRenderForm() != null);
        System.assert(w.getClickCommand() == null);
        System.assert(w.getCancelClickCommand() == null);
    }    
}