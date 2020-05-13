@isTest


private class Request_Overview_Control_Test {

    @isTest static void Request_Overview_Control_Test_Run () {
        
        Request_Overview_Control roc = new Request_Overview_Control();
        
        roc.Run_Report_Default();
        roc.Run_Report_Custom();
        roc.Run_Report_Custom_Reports();
        roc.buildCal(2019, 'null');
         roc.buildCal(2019, 'FullTeam');
                 roc.buildCal(2020, 'null');
         roc.buildCal(2020, 'FullTeam');
         roc.StatusToColor('Rejected');
         List<SelectOption> adminList =  roc.UserList;
               List<SelectOption> leadList =  roc.UserListReports;
    }
    
    
}