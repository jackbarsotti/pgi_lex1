public class Request_Overview_Control  {

public String Result_Panel {get; set;}
public String Selected_User{ get; set; }
public String Selected_User_Reports{ get; set; }

public boolean adminOnly {get; set;}
public boolean leadOnly {get; set;}
 
   public void Run_Report_Default()
   {
     leadOnly = true;
                 
                 
     id id1 = userinfo.getUserId();
     Integer User_Level = Get_User_Level_Admin(id1);
     
     if(User_Level == 4 || User_Level == 5)
     {
       adminOnly = true;
     }
     else 
     {
       adminOnly = false;
     }
     
     Integer User_Level_Lead = Get_User_Level_Lead(id1);
     
     if(User_Level_Lead == 3)
     {
       leadOnly = true;
     }
     else 
     {
       leadOnly = false;
     }
     
     
     
     Run_Report_ThisYear();

   
   }
 
    public void Run_Report_Custom()
    {
            id id1 = userinfo.getUserId();
            Integer User_Level = Get_User_Level_Admin(id1);
        
            if(User_level == 5  || User_level == 4)   // 'System Administrator' or '*PGI Scheduler*'
                {           
                    Result_Panel = '';
                    buildCal(system.today().year(), Selected_User);
                }
        
    }
 
 
 
 
 
 public void Run_Report_Custom_Reports()
 {
      id id1 = userinfo.getUserId();
     Integer User_Level = Get_User_Level_Lead(id1);
  
     
    if(User_level == 3)  // Has Direct Reports
    {
         Result_Panel = '';
               buildCal(system.today().year(), Selected_User_Reports);
    }
    
   
 }
 
 
 
        public void Run_Report_ThisYear()
     {
               
      Result_Panel = '';
             buildCal(system.today().year(), 'null');
     }
     

     
     public void buildCal(Integer year, String User_To_Run)
     {
     
     String result = '<table style="border-collapse: collapse;" border=1><tr>';
     
     Boolean Full_Team = (User_To_Run == 'FullTeam');

    
     date myDate = date.newInstance(year, 1, 1);
     date endDate = date.newInstance(year + 2, 1, 1);
     List <TO_Request__c>  requests;
     
     
      if(Full_Team)
     {
     requests =  Run_Report(year, true);
     }
     else {
       
     
     if(User_To_Run == 'null') 
     {
       requests =  Run_Report(year, false);
     }
     else {
       requests =  Run_Report(year, User_To_Run);
       }
     }
     
     
     Integer currentMonth = 999;
  
     Integer inMonthCount = 0;     
     Integer inWeekCount = -1;

  
     if(myDate != myDate.toStartOfWeek())
     {
        inWeekCount =  -1 -myDate.daysBetween(myDate.toStartOfWeek()); 
     
     }
          
             
     for(Integer i=0;myDate < endDate;i++)
     {

    if(currentMonth  != myDate.month())
        {
        inMonthCount = 0; 
        if(myDate.year() != year) { year =  myDate.year();} 
 
  
        Integer tempInWeekCount = inWeekCount;
        while(tempInWeekCount  < 6 && i > 15)
        {
          tempInWeekCount ++;
          result += '<td bgcolor="#f6f6f6">&nbsp</td>'; 
        }
        
        

        
        result += '</tr><tr><td colspan=7 align=center bgcolor="#DAEEF3"><strong>'  + Month_To_TXT(myDate.month())  + ' '  + String.valueOf(year) + '</strong></td></tr><tr>';
     
        tempInWeekCount = inWeekCount;
        
        while(tempInWeekCount  > -1 && tempInWeekCount  < 6)
        {
          tempInWeekCount --;
          result += '<td bgcolor="#f6f6f6">&nbsp</td>'; 
        }
        
  
        
        
             
        currentMonth  = myDate.month();
        }
    
    
    
    
       inMonthCount++;
       inWeekCount++;
       
       if(inWeekCount == 7)
       {
       inWeekCount = 0;
       result += '</tr><tr>';
       }

        
        
     
     String  thisCell = '';
     Boolean found = false;
     
 for(TO_Request__c thisRecord : requests )
         {
        if(thisRecord.Local_Start__c.addHours(1) >= myDate && thisRecord.Local_Start__c.addHours(1) < myDate.addDays(1))
         {
         found = true;
         String fontColor = StatusToColor(thisRecord.Status__c);
         if(Full_Team)
       {
                 thisCell += '<div style=\'background-color:' + fontColor  + '\'><a href=\'/' + thisRecord.Id +  '\'>' +  thisRecord.Resource__r.Name  + '</font></a></div>';
  
       }
       else 
       {
                 thisCell += '<div style=\'background-color:' + fontColor  + '\'><a href=\'/' + thisRecord.Id +  '\'>' +  thisRecord.Leave_Type__c + '</font></a></div>';
  
       }
       
       
           }
              
     }
     
     
     
     if(found == true)
     { 
          result += '<td width=100px>' + String.valueOf(inMonthCount ) + + thisCell + '</td>';
     
     }
     else {
     
          result += '<td width=100px>' + String.valueOf(inMonthCount ) + '<br/>&nbsp;</td>';
     
     }
          
     myDate  = myDate.addDays(1);
     
     }
     
     result += '</tr></table>';
     
     Result_Panel +=  result;
     
     
     }
     
     public string StatusToColor(String status)
    {
        string ret = '#ffffff';
          
        if(status == 'Approved') { ret  = '#8ff79b'; }
        if(status == 'Approved (Cancellation Requested)') { ret  = '#808000'; }
        if(status == 'Pending') { ret  = '#FFFF00'; }
        if(status == 'Pending (Cancellation Requested)') { ret  = '#BDB76B'; }
        if(status == 'Denied') { ret  = '#ef6b6b'; }
        if(status == 'Canceled') { ret  = '#A9A9A9'; } 
        
        return(ret);
    }
     
     
    public  String Month_To_TXT(Integer month)
    {
        if(month == 1)  { return('January');  }
        if(month == 2)  { return('February');  }
        if(month == 3)  { return('March');  }
        if(month == 4)  { return('April');  }
        if(month == 5)  { return('May');  }
        if(month == 6)  { return('June');  }
        if(month == 7)  { return('July');  }
        if(month == 8)  { return('August');  }
        if(month == 9)  { return('September');  }
        if(month == 10)  { return('October');  }
        if(month == 11)  { return('November');  }
        if(month == 12)  { return('December');  }
 
        return('###');
    }

    public Integer Get_User_Level_Admin(id This_User)
    {
        Integer  User_Level = 0;
        
        String Profile_Name = [Select Profile.Name from User  where Id=:This_User].Profile.Name;
        if(Profile_Name == 'System Administrator')  { User_Level = 5;  }
        if(Profile_Name.contains('PGi Service Dispatchers'))  { User_Level = 4; }
        if(this_user == '005a000000ApwR6')  { User_Level = 5;  }
   
        return(User_Level);    
    }       
     
         
     public Integer Get_User_Level_Lead(id This_User)
     {
       Integer  User_Level = 0;
      
      User_Temp = [Select u.Name, u.Id  From ServiceResource    u  Where User__r.ManagerID=:this_User or  User__r.ID=:this_User order by u.Name];
       
    if(User_Temp.size() > 1)
      {
        User_Level = 3;
      }   
             
       return(User_Level);    
       
     }     
     
     
     
     
     
     public List <TO_Request__c> Run_Report(Integer year, Boolean Full_Team)
     {
     
   date startDate = date.newInstance(year, 1, 1).addDays(-2);
     date endDate = date.newInstance(year + 2, 1, 1).addDays(2);
     
     
     
         List <TO_Request__c> roles;
         
         
         if(Full_Team)
         {
           roles = [Select 

id,Leave_Type__c ,  Status__c, Local_Start__c, Resource__r.Name

 from TO_Request__c

Where My_Team_Member__c = true and Local_Start__c > :startDate and Local_Start__c < :endDate

];     
         }
else { 
        roles = [Select 

id,Leave_Type__c,  Status__c, Local_Start__c

 from TO_Request__c

Where My_Request__c = true and Local_Start__c > :startDate and Local_Start__c < :endDate

];   

}
        
    
     return(roles);
     
     }
     
      public List <TO_Request__c> Run_Report(Integer year, id Custom_User)
     {
     
   date startDate = date.newInstance(year, 1, 1).addDays(-2);
     date endDate = date.newInstance(year + 2, 1, 1).addDays(2);
     
     
     
         List <TO_Request__c> roles = [Select 

id,Leave_Type__c ,  Status__c, Local_Start__c

 from TO_Request__c

Where  Resource__c  =:Custom_User  and Local_Start__c  > :startDate and Local_Start__c < :endDate

];     
        
    
     return(roles);
     
     }
     
  
     
     
        public List<ServiceResource> User_Temp = new List<ServiceResource>();
                

    
          
public List<SelectOption> UserList
    {
   
        get
        {
        id id1 = userinfo.getUserId();
     Integer User_Level = Get_User_Level_Admin(id1);
  
     if(User_level == 5  || User_level == 4) 
      {
      }
      else 
      {
         return(null);
      }
      
      
      
            User_Temp = [Select u.Name, u.Id  From ServiceResource u order by u.Name];
            
            UserList = new List<SelectOption>();
            
             UserList.add(new SelectOption('null', 'Please Select....'));
            
            for(ServiceResource temp : User_Temp)
            {
                UserList.add(new SelectOption(temp.Id, temp.Name));
            }
            return UserList;
        }
        set;
    }
    
    
      
     
     public List<SelectOption> UserListReports
    {
        get
        {
        
          id this_User =   userinfo.getUserId();
            
             User_Temp = [Select u.Name, u.Id  From ServiceResource  u  Where User__r.ManagerID=:this_User or  User__r.ID=:this_User order by u.Name];
                        
            UserListReports = new List<SelectOption>();
            
             UserListReports.add(new SelectOption('null', 'Please Select....'));

            UserListReports.add(new SelectOption('FullTeam', 'Full Team Overview'));
            
            for(ServiceResource   temp : User_Temp)
            {
                UserListReports.add(new SelectOption(temp.Id, temp.Name));
            }
            return UserListReports;
        }
        set;
    }
    
    
    
    
     
 }