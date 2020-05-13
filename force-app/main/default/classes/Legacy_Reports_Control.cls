public class Legacy_Reports_Control {

     public String Result_Panel {get; set;}
     public Date ReportDate {get;set;}
     public Boolean Exclude { get; set;}

          
                    
     public void Page_Load()
     {
     ReportDate  = date.today();
     }
     
     
             public void Run_Report()
    {
    Date ReportDatePlus = ReportDate.addDays(1);
  
  
  

    
    
 List <ServiceAppointment> roles = [  
Select 
    Work_Order__r.Conference__r.Conference_ID__c,
    Work_Order__r.Conference__r.Call_Start__c, 
    Work_Order__r.Conference__r.Call_End__c ,  
    Work_Order__r.Conference__r.Pre_Conference__c,
    Work_Order__r.Company__c, 
    Work_Order__r.Conference__r.Lead_Bridge__c,
    Work_Order__r.Conference__r.Linked_Bridges__c,
    Work_Order__r.Conference__r.Call_Type__c,
    Work_Order__r.Conference__r.Total_Ports__c,
    Work_Order__r.Conference__r.Status__c, 
    Assigned_Resource__c,
    WorkType.Name,
    Role_Not_Needed__c
    

    
    

 from ServiceAppointment
 
 
Where (Is_CallRole__c = true or Work_Order__r.Conference__r.Lead_Bridge__c != '')
and  isDeleted = false
and Status != 'Canceled'
and Work_Order__r.Conference__r.Call_Start__c  >= :ReportDate
and Work_Order__r.Conference__r.Call_Start__c  < :ReportDatePlus
and Work_Order__r.Conference__r.Company__r.Exclude_From_Reports__c = :Exclude 



Order by Work_Order__r.Conference__r.Call_Start__c, Work_Order__r.Conference__r.Conference_ID__c
];





         String result = '<table class="ams"><tr><th>ConfID</th><th>StartTime</th><th>EndTime</th><th>Pre</th><th>Company</th><th>Bridge</th><th>ServiceLevel</th><th>Ports</th><th>Lead</th><th>2nd</th><th>CommLine</th><th>Passdown</th><th>AnswerLines</th></tr>';
     
     String LastConfID ='xxx';
     String status;
     String thisConfID;
     String ConfId;
     Datetime StartTime;
     Datetime EndTime;
     Datetime Pre;
     String Company;
     String Bridge;
     String ServiceLevel;
     Decimal Lines;
     String Lead;
     String LeadAssist;
     String CommLine;
     String Passdown;
     String AnswerLines;
     
     
         for(ServiceAppointment thisRecord : roles  )
         {
  
         
                  
         
             thisConfID = thisRecord.Work_Order__r.Conference__r.Conference_ID__c;
         
         
  

         
         if(thisConfID != LastConfID)
         {
         if(LastConfID != 'xxx') 
         {
         
         if(status == 'Canceled')
         {
            result += '<tr style="text-decoration: line-through;">';
         }
         else {
            result += '<tr>';
         }
         
      
result += '<td>' + ConfId + '</td>';

if(StartTime != null)
{
result += '<td>' + StartTime.format('HH:mm:ss') + '</td>';
}
else{
result += '<td>????</td>';
}


if(EndTime != null)
{
result += '<td>' + EndTime.format('HH:mm:ss') + '</td>';
}
else{
result += '<td>????</td>';
}
Long Datediff = 0; 

if(StartTime != null && Pre != null)
{
Datediff =  (StartTime.getTime() - Pre.getTime()) / 60000;
}

result += '<td>' + Datediff  + '</td>';
result += '<td>'+ Company + '</td>';
result += '<td>' + Bridge + '</td>';
result += '<td>' + ServiceLevel + '</td>';
result += '<td>' + Lines + '</td>';

if(Lead.Contains('Unstaffed')) {  result += '<td class="red"> ' + Lead + '</td>'; }
else{ result += '<td>' + Lead + '</td>'; }

if(LeadAssist.Contains('Unstaffed')) {  result += '<td class="red"> ' + LeadAssist + '</td>'; }
else{ result += '<td>' + LeadAssist + '</td>'; }

if(CommLine.Contains('Unstaffed')) {  result += '<td class="red"> ' + CommLine + '</td>'; }
else{ result += '<td>' + CommLine + '</td>'; }

if(Passdown.Contains('Unstaffed')) {  result += '<td class="red"> ' + Passdown + '</td>'; }
else{ result += '<td>' + Passdown + '</td>'; }

if(AnswerLines.Contains('Unstaffed')) {  result += '<td class="red"> ' + AnswerLines + '</td>'; }
else{ result += '<td>' + AnswerLines + '</td>'; }


result += '</tr>';
}


   ConfId = thisRecord.Work_Order__r.Conference__r.Conference_ID__c;
            StartTime = thisRecord.Work_Order__r.Conference__r.Call_Start__c;
EndTime = thisRecord.Work_Order__r.Conference__r.Call_End__c;
Pre = thisRecord.Work_Order__r.Conference__r.Pre_Conference__c;


Company = thisRecord.Work_Order__r.Company__c;


if(thisRecord.Work_Order__r.Conference__r.Linked_Bridges__c == null)
{
Bridge = thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c;

}
else {
Bridge = thisRecord.Work_Order__r.Conference__r.Linked_Bridges__c;
}


ServiceLevel = thisRecord.Work_Order__r.Conference__r.Call_Type__c;
Lines = thisRecord.Work_Order__r.Conference__r.Total_Ports__c;
status = thisRecord.Work_Order__r.Conference__r.Status__c;
Lead = '';
LeadAssist  = '';
CommLine  = '';
Passdown  = '';
AnswerLines = '';


LastConfID = thisConfID;
         }
         
         
         string thisResource = thisRecord.Assigned_Resource__c ;
         
         if(thisResource == null || thisResource == '')
         { 
         thisResource = 'Unstaffed';
         }
         
         if(thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c  != null)
         {
         thisResource += ' (' + thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c  + ')';
         }
         
         
         
                  
                  
         string workTypeName = ''; 
         
         if(thisRecord.WorkType.Name != null) {
         workTypeName  = thisRecord.WorkType.Name;
         }
         
         if(workTypeName.Contains('Lead'))
         {    
         
         ServiceLevel = thisRecord.WorkType.Name.replace('Lead','');
         
           
            if(thisRecord.Role_Not_Needed__c)
         {
         if(Lead.length() > 0) { Lead += ', ';} 
         Lead += 'Role Not Needed';
         }
         else {
              if(Lead.length() > 0) { Lead += ', ';} 
         Lead += thisResource;
         
         }
         
         }
         
         
                  
         if(workTypeName.Contains('CommLine'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(CommLine.length() > 0) { CommLine  += ', ';} 
         CommLine  += 'Role Not Needed';
         }
         else {
               if(CommLine.length() > 0) { CommLine  += ', ';} 
         CommLine  += thisResource ;
         }
         
         }
         
         
           if(workTypeName.Contains('2nd'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(LeadAssist.length() > 0) { LeadAssist += ', ';} 
         LeadAssist += 'Role Not Needed';
         }
         else {
               if(LeadAssist.length() > 0) { LeadAssist += ', ';} 
         LeadAssist += thisResource ;
         }
         
         }
         
                 if(workTypeName.Contains('Passdown'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(Passdown.length() > 0) { Passdown+= ', ';} 
         Passdown+= 'Role Not Needed';
         }
         else {
               if(Passdown.length() > 0) { Passdown+= ', ';} 
         Passdown+= thisResource ;
         }
         
         }



        if(workTypeName.Contains('AL')  || workTypeName.Contains('Transcriber')  || workTypeName.Contains('Answer'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(AnswerLines.length() > 0) { AnswerLines+= ', ';} 
         AnswerLines+= 'Role Not Needed';
         }
         else {
               if(AnswerLines.length() > 0) { AnswerLines+= ', ';} 
         AnswerLines+= thisResource;
         }
         
         }

    
         }
         
     
   
   if(thisConfID != 'xxx' && thisConfID != null)
   {
    result += '<tr>';
result += '<td>' + ConfId + '</td>';

if(StartTime != null)
{
result += '<td>' + StartTime.format('HH:mm:ss') + '</td>';
}
else{
result += '<td>????</td>';
}


if(EndTime != null)
{
result += '<td>' + EndTime.format('HH:mm:ss') + '</td>';
}
else{
result += '<td>????</td>';
}





Long Datediff = 0; 

if(StartTime != null && Pre != null)
{
Datediff =  (StartTime.getTime() - Pre.getTime()) / 60000;
}

result += '<td>' + Datediff  + '</td>';
result += '<td>' + Company + '</td>';
result += '<td>' + Bridge + '</td>';
result += '<td>' + ServiceLevel + '</td>';
result += '<td>' + Lines + '</td>';

if(Lead.Contains('Unstaffed')) {  result += '<td class="red"> ' + Lead + '</td>'; }
else{ result += '<td>' + Lead + '</td>'; }

if(LeadAssist.Contains('Unstaffed')) {  result += '<td class="red"> ' + LeadAssist + '</td>'; }
else{ result += '<td>' + LeadAssist + '</td>'; }

if(CommLine.Contains('Unstaffed')) {  result += '<td class="red"> ' + CommLine + '</td>'; }
else{ result += '<td>' + CommLine + '</td>'; }

if(Passdown.Contains('Unstaffed')) {  result += '<td class="red"> ' + Passdown + '</td>'; }
else{ result += '<td>' + Passdown + '</td>'; }

if(AnswerLines.Contains('Unstaffed')) {  result += '<td class="red"> ' + AnswerLines + '</td>'; }
else{ result += '<td>' + AnswerLines + '</td>'; }


result += '</tr>';
         }
     
     


     Result_Panel = result + '</table>';
     
    
    }
    
     
 
   public void Run_Staffing_Review()
     {
     
        Date ReportDatePlus = ReportDate.addDays(1);
     
             
 List <ServiceAppointment> roles = [  
Select 
    Work_Order__r.Conference__r.Conference_ID__c,
    Work_Order__r.Conference__r.Call_Start__c, 
    Work_Order__r.Conference__r.Call_End__c ,  
    Work_Order__r.Conference__r.Pre_Conference__c,
    Work_Order__r.Company__c, 
    Work_Order__r.Conference__r.Lead_Bridge__c,
    Work_Order__r.Conference__r.Linked_Bridges__c,
    Work_Order__r.Conference__r.Call_Type__c,
    Work_Order__r.Conference__r.Total_Ports__c,
    Work_Order__r.Conference__r.Status__c, 
    Assigned_Resource__c,
    WorkType.Name,
    Role_Not_Needed__c
    ,Work_Order__r.Conference__r.id

 from ServiceAppointment

Where (Is_CallRole__c = true or Work_Order__r.Conference__r.Lead_Bridge__c != '')

and isDeleted = false


and Status != 'Canceled'

and Work_Order__r.Conference__r.Call_Start__c  >= :ReportDate
and Work_Order__r.Conference__r.Call_Start__c  < :ReportDatePlus


and Work_Order__r.Conference__r.Company__r.Exclude_From_Reports__c = :Exclude 

Order by Work_Order__r.Conference__r.Call_Start__c, Work_Order__r.Conference__r.Conference_ID__c


];     



        
String result = '<table class="ams"><tr><th>ConfID</th><th style="text-align:center">StartTime<br/>(Ireland)</th><th style="text-align:center">StartTime<br/>(Central)</th><th>Company</th><th>Bridges</th><th>ServiceLevel</th><th>Ports</th><th>Lead</th><th>2nd</th><th>CommLine</th><th>Passdown</th>';
result += '<th style="text-align:center">Total<br/>AL/NOE<br/>Roles</th><th style="text-align:center">AL/NOE<br/>Roles<br/>Unfilled</th><th style="text-align:center">% Of<br/>AL/NOE<br/>Roles Filled</th></tr>';
     
     String LastConfID ='xxx';
     String status;
     String thisConfID;
     String ConfId;
     Datetime StartTime;
     Datetime EndTime;
     Datetime Pre;
     String Company;
     String Bridge;
     String ServiceLevel;
     Decimal Lines;
     String Lead;
     String LeadAssist;
     String CommLine;
     String Passdown;
     String AnswerLines;
     Decimal  TotalALs = 0;
     Decimal  TotalUnstaffedALs = 0;
     
     
     
         for(ServiceAppointment thisRecord : roles )
         {
         thisConfID = thisRecord.Work_Order__r.Conference__r.Conference_ID__c;
         
         if(thisConfID != LastConfID)
         {
         if(LastConfID != 'xxx') 
         {
         
         if(status != 'Canceled')
         {
       
            result += '<tr>';
        
         
      
result += '<td>' + ConfId + '</td>';


if(StartTime != null)
{
result += '<td>' + StartTime.format('HH:mm:ss','Europe/Dublin') + '</td>';
result += '<td>' + StartTime.format('HH:mm:ss','America/Chicago') + '</td>';
}
else{
result += '<td>????</td><td>????</td>';
}




string extraSyle = '';


if(Company.Contains('Goldman') || Company.Contains('Citi')) {  extraSyle = 'class="blue"'; }
if(Company.Contains('Outsourced')) {  extraSyle = 'class="yellow"'; }

else{ result += '<td ' + extraSyle + '>' + Company + '</td>'; }

Integer Bridges = 1;

for(Integer i=0;i<Bridge.Length();i++)
{
if(Bridge.Substring(i,i + 1) == ',') { Bridges++;  }
}

result += '<td>' + Bridges + '</td>';
result += '<td>' + ServiceLevel + '</td>';
result += '<td>' + Lines + '</td>';


extraSyle = '';
if(Lead.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(Lead.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + Lead + '</td>'; 


extraSyle = '';
if(LeadAssist.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(LeadAssist.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + LeadAssist+ '</td>'; 


extraSyle = '';
if(CommLine.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(CommLine.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + CommLine + '</td>'; 



extraSyle = '';
if(Passdown.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(Passdown.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + Passdown + '</td>'; 

if(TotalALs  == 0)
{


if(ServiceLevel.Contains('Event') || ServiceLevel.Contains('Greeted')  )
{
result  += '<td class="red" style="text-align:center">0</td><td></td><td></td>';
}
else
{
result  += '<td></td><td></td><td></td>';
}



}
else
{
extraSyle = '';

result += '<td style="text-align:center">' + TotalALs + '</td>'; 

if(TotalUnstaffedALs  > 0) {  

if(ServiceLevel.Contains('PCE')  || ServiceLevel.Contains('Passcode')) { extraSyle = 'class="orange"';    }
else { 
     extraSyle = 'class="red"';    
     }


}
else {  extraSyle = ''; } 

result += '<td ' + extraSyle + ' style="text-align:center">' + TotalUnstaffedALs + '</td>'; 

extraSyle = '';

result += '<td style="text-align:center">' + (100 - ((TotalUnstaffedALs / TotalALs) * 100).intValue())  +'%</td>'; 
}


result += '</tr>';
}
 }

   ConfId = thisRecord.Work_Order__r.Conference__r.Conference_ID__c;
            StartTime = thisRecord.Work_Order__r.Conference__r.Call_Start__c;
EndTime = thisRecord.Work_Order__r.Conference__r.Call_End__c;
Pre = thisRecord.Work_Order__r.Conference__r.Pre_Conference__c;


Company = thisRecord.Work_Order__r.Company__c;


if(thisRecord.Work_Order__r.Conference__r.Linked_Bridges__c == null)
{
Bridge = thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c;

}
else {
Bridge = thisRecord.Work_Order__r.Conference__r.Linked_Bridges__c;
}


if(thisRecord.Work_Order__r.Conference__r.Call_Type__c == null)
{
    ServiceLevel  = '???';
}
else {
    ServiceLevel = thisRecord.Work_Order__r.Conference__r.Call_Type__c;
}






Lines = thisRecord.Work_Order__r.Conference__r.Total_Ports__c;
status = thisRecord.Work_Order__r.Conference__r.Status__c;
Lead = '';
LeadAssist  = '';
CommLine  = '';
Passdown  = '';
AnswerLines = '';
TotalALs = 0;
TotalUnstaffedALs = 0;

 
LastConfID = thisConfID;
         }
        
         
         string thisResource = thisRecord.Assigned_Resource__c;
         
         if(thisResource == null || thisResource == '')
         { 
         thisResource = 'Unstaffed';
         }
         
                  if(thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c  != null)
         {
         thisResource += ' (' + thisRecord.Work_Order__r.Conference__r.Lead_Bridge__c  + ')';
         }
         
         
         string workTypeName = ''; 
         
         if(thisRecord.WorkType.Name != null) {
         workTypeName  = thisRecord.WorkType.Name;
         }
         
         
         
         if(workTypeName.Contains('Lead'))
         {    
         
         if(ServiceLevel == '???')
         {    
               ServiceLevel = thisRecord.WorkType.Name.replace('Lead','');
         
         
         }
         
 
           
            if(thisRecord.Role_Not_Needed__c)
         {
         if(Lead.length() > 0) { Lead += ', ';} 
         Lead += 'Role Not Needed';
         }
         else {
              if(Lead.length() > 0) { Lead += ', ';} 
         Lead += thisResource ;
         }
         
         }
         
         
                  
         if(workTypeName.Contains('CommLine'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(CommLine.length() > 0) { CommLine  += ', ';} 
         CommLine  += 'Role Not Needed';
         }
         else {
               if(CommLine.length() > 0) { CommLine  += ', ';} 
         CommLine  += thisResource ;
         }
         
         }
         
         
           if(workTypeName.Contains('2nd'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(LeadAssist.length() > 0) { LeadAssist += ', ';} 
         LeadAssist += 'Role Not Needed';
         }
         else {
               if(LeadAssist.length() > 0) { LeadAssist += ', ';} 
         LeadAssist += thisResource ;
         }
         
         }
         
                 if(workTypeName.Contains('Passdown'))
         {    
         
            if(thisRecord.Role_Not_Needed__c)
         {
               if(Passdown.length() > 0) { Passdown+= ', ';} 
         Passdown+= 'Role Not Needed';
         }
         else {
               if(Passdown.length() > 0) { Passdown+= ', ';} 
         Passdown+= thisResource ;
         }
         
         }



        if(workTypeName.Contains('AL')  || workTypeName.Contains('Transcriber')  || workTypeName.Contains('Answer'))
         {    
         
           TotalALs++;
           
           if(thisResource.Contains('Unstaffed') && !thisRecord.Role_Not_Needed__c ) { TotalUnstaffedALs++; } 
         
         }

}

         
   
   if(thisConfID != 'xxx' && thisConfID != null)
   {
  
         if(status != 'Canceled')
         {
       
            result += '<tr>';
        
         
      
result += '<td>' + ConfId + '</td>';

if(StartTime != null)
{
result += '<td>' + StartTime.format('HH:mm:ss','Europe/Dublin') + '</td>';
result += '<td>' + StartTime.format('HH:mm:ss','America/Chicago') + '</td>';
}
else{
result += '<td>????</td><td>????</td>';
}




string extraSyle = '';


if(Company.Contains('Goldman') || Company.Contains('Citi')) {  extraSyle = 'class="blue"'; }
if(Company.Contains('Outsourced')) {  extraSyle = 'class="yellow"'; }

else{ result += '<td ' + extraSyle + '>' + Company + '</td>'; }

Integer Bridges = 1;

for(Integer i=0;i<Bridge.Length();i++)
{
if(Bridge.Substring(i,i + 1) == ',') { Bridges++;  }
}


result += '<td>' +  Bridges + '</td>';
result += '<td>' + ServiceLevel + '</td>';
result += '<td>' + Lines + '</td>';


extraSyle = '';
if(Lead.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(Lead.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + Lead + '</td>'; 


extraSyle = '';
if(LeadAssist.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(LeadAssist.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + LeadAssist+ '</td>'; 


extraSyle = '';
if(CommLine.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(CommLine.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + CommLine + '</td>'; 



extraSyle = '';
if(Passdown.Contains('Unstaffed')) {  extraSyle = 'class="red"'; }
if(Passdown.Contains('Role Not Needed')) {  extraSyle = 'class="green"'; }
result += '<td ' + extraSyle + '>' + Passdown + '</td>'; 

if(TotalALs  == 0)
{




if(ServiceLevel.Contains('Event') || ServiceLevel.Contains('Greeted') )
{
result  += '<td class="red">0</td><td></td><td></td>';
}
else
{
result  += '<td></td><td></td><td></td>';
}



}
else
{
extraSyle = '';

result += '<td style="text-align:center" style="text-align:center">' + TotalALs + '</td>'; 

if(TotalUnstaffedALs  > 0) { 

if(ServiceLevel.Contains('PCE') || ServiceLevel.Contains('Passcode')) { extraSyle = 'class="orange"';    }
else { 
     extraSyle = 'class="red"';    
     }
     
     
     }
else {  extraSyle = ''; } 

result += '<td ' + extraSyle + ' style="text-align:center">' + TotalUnstaffedALs + '</td>'; 

extraSyle = '';

result += '<td style="text-align:center">' + (100 - ((TotalUnstaffedALs / TotalALs) * 100).intValue())  +'%</td>'; 
}


result += '</tr>';
}
}




       Result_Panel = result + '</table>';
     
     }
     
              
}