({
    handleClick : function (component, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
       var url = '/one/one.app#/alohaRedirect/apex/OpportunityImplementationAutomation?id='+userId;
       var myWindow = window.open(url, "", "width=1366,height=728");
    }	
})