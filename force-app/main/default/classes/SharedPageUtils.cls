public class SharedPageUtils {
	private static Set<String> passForwardParams = new Set<String>{'retURL', 'isClassic', 'isNew', 'saveUrl', 'Id', 'RecordType', 'RecordTypeId', 'QuickCase', LABEL.Related_SCA_Id, LABEL.Related_SCA_Id + '_lkid'};
    public static PageReference passForwardParams(PageReference pr) {
    	if(pr != null) {
	    	PageReference cp = ApexPages.currentPage();
			for(String s: cp.getParameters().keySet()){
				if(passForwardParams.contains(s)){
					pr.getParameters().put(s, cp.getParameters().get(s));
				}
			}
		}
        return pr;
    }
    public static String getParameter(String parameter) {
    	PageReference cp = ApexPages.currentPage();
		return cp.getParameters().get(parameter);
    }
}