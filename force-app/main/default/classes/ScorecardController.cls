/*
    Class : ScorecardController
*/
public class ScorecardController{
     
    public List<Case> lstCase{get;set;}
    public Integer TotalOpenCases{get;set;}
    public Integer TotalClosedCases{get;set;}
    public Integer TotalCases{get;set;}
    public String showDatafor{get;set;}
    public List<ModelClass> lstModelClass{get;set;}
    public List<Vendor_Scorecard__c> LVenScore{get;set;}
    public Id currentVid{get;set;}
    public String VName{get;set;}
    public Integer pageNumber{get;set;}
    public Integer TotalPages{get;set;}
    public Boolean preBtnDisabled{get;set;}
    public Boolean nxtBtnDisabled{get;set;}
    public set<Id> setVendorIdWithSurveys{get;set;}
    public set<Id> setVendorIdWithoutSurveys{get;set;}
    public Boolean hidetable{get;set;}
    public Integer pagesCount{get;set;}
    public map<Id,Integer> mapforPageNumber{get;set;}
    public map<Id,String> mapVendorName{get;set;}
    public boolean chkURLError{get;set;}
    public Date theGivenMonthDate{get;set;}
    
    
    public ScorecardController(){
        showDatafor = '';
        currentVid = Null;
        preBtnDisabled = true;
        nxtBtnDisabled = false; 
        pagesCount = 0; 
        VName = '';
        hidetable = false; 
        lstCase = new List<Case>();
        TotalOpenCases = 0;
        TotalClosedCases = 0;
        TotalCases = 0;
        lstModelClass = new List<ModelClass>();
        mapVendorName  = new map<Id,String>();
        mapforPageNumber  = new map<Id,Integer>();
        pageNumber = 1;
        TotalPages = 1;
        
        //get data from url 
        showDatafor = apexpages.currentpage().getParameters().get('data');  
        
        //Fatch vendors with survey records
        setVendorIdWithSurveys = vendorHaveSurvey();      
         //Fatch vendors without survey records 
        setVendorIdWithoutSurveys = vendorHaveWithoutSurvey(setVendorIdWithSurveys);  
        
        //Call first record 
        if( '' != showDatafor  && Null != showDatafor  && showDatafor.length()== 8 && setVendorIdWithoutSurveys!= Null){
            
            LVenScore= [Select id,Related_PGi_Vendor__c,Month_Year__c,Related_PGi_Vendor__r.Id,Related_PGi_Vendor__r.Name  from Vendor_Scorecard__c Where Month_Year__c =: showDatafor and Related_PGi_Vendor__c IN:setVendorIdWithoutSurveys and Related_PGi_Vendor__r.Show_on_Surveys__c = true ORDER BY Related_PGi_Vendor__r.Id];           
            if(LVenScore != Null && LVenScore.size()>0){
                currentVid = LVenScore.get(0).Related_PGi_Vendor__r.Id;
                if(currentVid != Null){
                    loadQestionAnswer(currentVid,showDatafor);
                    pageNumber = mapforPageNumber.get(currentVid);  
                }  
            }else{
                hidetable = true;
            }           
        }else{
            if(Null == showDatafor || '' == showDatafor){
                chkURLError = true;
            }else{
                hidetable = true;
            }
        }  
    }
    
    //This method used to call next vendor survey record.
    public void nextVendor(){
          
        preBtnDisabled = false;
        List<Vendor_Survey__c> lsVs = new List<Vendor_Survey__c>();
        Vendor_Survey__c vs = new Vendor_Survey__c();
        
        Boolean isInsert = false;
        
        if(lstModelClass!= Null && lstModelClass.size()>0){
            for(ModelClass mc : lstModelClass){
                if(mc.isApp == null){
                }else{
                    if(mc.question == 'Communicates network impacting issues' ){
                        vs.Communicates_network_impacting_issues__c = Decimal.ValueOf(mc.isApp);
                    }
                    if(mc.question ==  'Familiar with PGi business and troubles' ){
                        vs.Familiar_with_PGi_business_and_trouble__c = Decimal.ValueOf(mc.isApp);
                    }
                    if(mc.question ==  'Knowledgeable of outstanding problems' ){
                        vs.Knowledgeable_of_outstanding_problems__c = Decimal.ValueOf(mc.isApp);
                    }
                    if(mc.question ==  'Provides accurate timely ticket updates' ){
                        vs.Provides_accurate_timely_ticket_updates__c = Decimal.ValueOf(mc.isApp);
                    }
                    if(mc.question ==  'Responsive when PGi escalations occur' ){
                        vs.Responsive_when_PGi_escalations_occur__c = Decimal.ValueOf(mc.isApp);
                    }
                    vs.Vendor_Scorecard__c = Id.ValueOf(mc.vScoreCardId);
                    if(mc.isSurveyId == Null){
                        isInsert = true;
                    }
                }
            }
            if(isInsert){
                lsVs.add(vs);
            }
            if(lsVs != Null && lsVs.size()>0){
                insert lsVs;
            }
        }
        lstModelClass.Clear();
        if(TotalPages == pageNumber){
            VName ='';
            nxtBtnDisabled = true;
            TotalOpenCases = 0;
            TotalClosedCases = 0;
            TotalCases = 0; 
            loadQestionAnswer(currentVid,showDatafor);
        }else{
            //Fatch vendors with survey records
            setVendorIdWithSurveys = vendorHaveSurvey();      
             //Fatch vendors without survey records 
            setVendorIdWithoutSurveys = vendorHaveWithoutSurvey(setVendorIdWithSurveys);    
            if(setVendorIdWithoutSurveys != Null && setVendorIdWithoutSurveys.size()>0){
                LVenScore = [Select id,Related_PGi_Vendor__c,Month_Year__c,Related_PGi_Vendor__r.Id,Related_PGi_Vendor__r.Show_on_Surveys__c,Related_PGi_Vendor__r.Name  from Vendor_Scorecard__c 
                        Where Month_Year__c =: showDatafor and Related_PGi_Vendor__r.Show_on_Surveys__c = true and Related_PGi_Vendor__r.Id >: currentVid and Related_PGi_Vendor__c IN:setVendorIdWithoutSurveys ORDER BY Related_PGi_Vendor__r.Id ];
                if(LVenScore != Null && LVenScore.size()>0){
                    currentVid = LVenScore.get(0).Related_PGi_Vendor__r.Id;
                    loadQestionAnswer(currentVid,showDatafor);
                    pageNumber = mapforPageNumber.get(currentVid);
                } 
            }else{
                nxtBtnDisabled = true;
            }
        } 
        if(pageNumber == 1){
            preBtnDisabled = true;
        }
    }
    //This method used to call privious vendor  survey record.
    public void previousVendor(){
        
        nxtBtnDisabled = false;
        if(pageNumber == 1){
            preBtnDisabled = true;
        }
        //Fatch vendors with survey records
        setVendorIdWithSurveys = vendorHaveSurvey();      
         //Fatch vendors without survey records 
        setVendorIdWithoutSurveys = vendorHaveWithoutSurvey(setVendorIdWithSurveys);  
        if(setVendorIdWithoutSurveys != Null && setVendorIdWithoutSurveys.size()>0){ 
            LVenScore = [Select id,Related_PGi_Vendor__c,Month_Year__c,Related_PGi_Vendor__r.Id,Related_PGi_Vendor__r.Show_on_Surveys__c,Related_PGi_Vendor__r.Name  from Vendor_Scorecard__c 
                            Where Month_Year__c =: showDatafor and Related_PGi_Vendor__r.Show_on_Surveys__c = true and Related_PGi_Vendor__r.Id <: currentVid and Related_PGi_Vendor__c IN:setVendorIdWithoutSurveys  ORDER BY Related_PGi_Vendor__r.Id DESC ];
            if(LVenScore != Null && LVenScore.size()>0){
                currentVid = LVenScore.get(0).Related_PGi_Vendor__r.Id;
                loadQestionAnswer(currentVid,showDatafor);
                pageNumber = mapforPageNumber.get(currentVid); 
            }   
        }
        if(pageNumber == 1){
            preBtnDisabled = true;
        }
    }
    //This method is used to initilaze the model class record on page. 
    public void loadQestionAnswer(Id selectedVendorId,String showDatafor){
        lstModelClass.Clear();
        
        if(selectedVendorId != Null ){
             
            String ftDate = calculateStartEndDate(showDatafor,true);
            String edDate = calculateStartEndDate(showDatafor,false);
            
            String qary = 'Select Id,Status,Subject,X3rd_Party_Vendor__c FROM Case WHERE (X3rd_Party_Vendor__c =:selectedVendorId OR X3rd_Party_Vendor_2__c =:selectedVendorId OR X3rd_Party_Vendor_3__c =:selectedVendorId) and (CreatedDate >='+ftDate+'  and CreatedDate <= '+edDate+')';
            lstCase = Database.query(qary);
            TotalCases = lstCase.size();
            qary = 'Select Id,Status,Subject,X3rd_Party_Vendor__c FROM Case WHERE Status = \'Closed\' AND (X3rd_Party_Vendor__c =:selectedVendorId OR X3rd_Party_Vendor_2__c =:selectedVendorId OR X3rd_Party_Vendor_3__c =:selectedVendorId) and  (ClosedDate >='+ftDate+'  and ClosedDate <= '+edDate+')';
            lstCase = Database.query(qary);
            //TotalOpenCases = lstCase.size();
            TotalClosedCases = lstCase.size();
            /* 
            system.debug(lstCase.size());
            lstCase = [Select Id,Status,Subject,Vendor__c from Case Where Vendor__c =:selectedVendorId and  Status != 'Closed' and  ( CreatedDate >=: Datetime.ValueOf(ftDate) and CreatedDate <=: Datetime.ValueOf(edDate)  )  ];
            system.debug(lstCase + ' - '+lstCase.size());
            List<CaseHistory> lstCH = [Select Id,CaseId  From CaseHistory Where Case.Vendor__c =: selectedVendorId and ((Field ='Closed') or (Field ='Status') ) and  ( CreatedDate >=: Datetime.ValueOf(ftDate) and CreatedDate <=: Datetime.ValueOf(edDate)  )  ];
            TotalOpenCases = lstCase.size();
            system.debug(lstCH + ' - '+lstCH.size());
            */
            LVenScore= [Select id,Communicates_network_impacting_issues__c,Familiar_with_PGi_business_and_troubles__c,
                                    Knowledgeable_of_outstanding_problems__c,Month_Year__c,Provides_accurate_timely_ticket_updates__c,
                                                Related_PGi_Vendor__c,Related_PGi_Vendor__r.Name,Responsive_when_PGi_escalations_occur__c from Vendor_Scorecard__c 
                                                    Where Related_PGi_Vendor__c =: selectedVendorId and Month_Year__c=:showDatafor];
            VName = mapVendorName.get(selectedVendorId);
            
            if(LVenScore != Null && LVenScore.size()>0 ){
                List<Vendor_Survey__c> lstVenSurvey = [Select id  from Vendor_Survey__c Where  Vendor_Scorecard__r.Related_PGi_Vendor__c =: selectedVendorId and Vendor_Scorecard__r.Month_Year__c =:showDatafor
                                                        and  Vendor_Scorecard__c =:LVenScore.get(0).Id and CreatedBy.Id =: UserInfo.getUserId()]; 
                if(lstVenSurvey.size()==0 ){
                    ModelClass mc = new ModelClass();
                    mc.question = 'Communicates network impacting issues';
                    mc.whichMonthYear = showDatafor;  
                    mc.vScoreCardId = LVenScore.get(0).id;
                    mc.isSurveyId = Null;
                    lstModelClass.add(mc);
                    
                    mc = new ModelClass();
                    mc.question = 'Familiar with PGi business and troubles';
                    mc.whichMonthYear = showDatafor;
                    mc.vScoreCardId = LVenScore.get(0).id;
                    mc.isSurveyId = Null;
                    lstModelClass.add(mc);
                
                    mc = new ModelClass();
                    mc.question = 'Knowledgeable of outstanding problems';
                    mc.whichMonthYear = showDatafor;
                    mc.vScoreCardId = LVenScore.get(0).id;
                    mc.isSurveyId = Null;
                    lstModelClass.add(mc);
                
                    mc = new ModelClass();
                    mc.question = 'Provides accurate timely ticket updates';
                    mc.whichMonthYear = showDatafor;
                    mc.vScoreCardId = LVenScore.get(0).id;
                    mc.isSurveyId = Null;
                    lstModelClass.add(mc);
                    
                    mc = new ModelClass();
                    mc.question = 'Responsive when PGi escalations occur';
                    mc.whichMonthYear = showDatafor;
                    mc.vScoreCardId = LVenScore.get(0).id;
                    mc.isSurveyId = Null;
                    lstModelClass.add(mc);
                }
            }
        }
    }
    
    //This method return the set of all vendors which have a survey record of current users.
    public set<Id> vendorHaveSurvey(){
        List<Vendor_Survey__c> lstVenSur = [Select id,Vendor_Scorecard__c,Vendor_Scorecard__r.Month_Year__c, Vendor_Scorecard__r.Related_PGi_Vendor__c from Vendor_Survey__c Where 
                                             Vendor_Scorecard__r.Month_Year__c =:showDatafor and  CreatedBy.Id =: UserInfo.getUserId()]; 
        set<Id> setVendorIds = new set<Id>();       
        if(lstVenSur!= Null && lstVenSur.size()>0){
            for(Vendor_Survey__c vs : lstVenSur ){
                setVendorIds.add(vs.Vendor_Scorecard__r.Related_PGi_Vendor__c);
            }
            return setVendorIds;
        } 
        return null;
    }
    //This method return the set of all vendors which does not have a survey record of current users.
     public set<Id> vendorHaveWithoutSurvey(set<Id> setVendorHaveSurvey){
        if(setVendorIdWithSurveys != Null && setVendorIdWithSurveys.size()>0){
            LVenScore= [Select id,Related_PGi_Vendor__c,Related_PGi_Vendor__r.Name  from Vendor_Scorecard__c Where Related_PGi_Vendor__r.Show_on_Surveys__c = true and Month_Year__c =: showDatafor and Related_PGi_Vendor__c NOT IN:setVendorHaveSurvey ORDER BY Related_PGi_Vendor__r.Id];
        }else{
            LVenScore= [Select id,Related_PGi_Vendor__c,Related_PGi_Vendor__r.Name  from Vendor_Scorecard__c Where Related_PGi_Vendor__r.Show_on_Surveys__c = true and  Month_Year__c =: showDatafor ORDER BY Related_PGi_Vendor__r.Id];            
        }
         
        pagesCount =1; 
        set<Id> setVendorIds = new set<Id>();       
        if(LVenScore!= Null && LVenScore.size()>0){
            for(Vendor_Scorecard__c vs : LVenScore ){
                setVendorIds.add(vs.Related_PGi_Vendor__c);
                mapforPageNumber.put(vs.Related_PGi_Vendor__c,pagesCount);
                pagesCount = pagesCount+1;
                mapVendorName.put(vs.Related_PGi_Vendor__c,vs.Related_PGi_Vendor__r.Name);
            }
            TotalPages = LVenScore.size();
            return setVendorIds; 
        } 
        return null; 
    }
    
    public static String calculateStartEndDate(String showDatafor,Boolean isStart){
        
        try{
            String tDate = '';
        
            String [] tVar= showDatafor.split('-');
             
            String tMonth = tVar[0];
            Integer tYear = Integer.ValueOf(tVar[1]);
            tMonth = tMonth.toLowerCase();
            Integer fMonth =0;
            
            if(tMonth == 'jan'){
                fMonth = 1;
            }else if(tMonth == 'feb'){
                fMonth = 2;
            }else if(tMonth == 'mar'){
                fMonth = 3;
            }else if(tMonth == 'apr'){
                fMonth = 4;
            }else if(tMonth == 'may'){
                fMonth = 5;
            }else if(tMonth == 'jun'){
                fMonth = 6;
            }else if(tMonth == 'jul'){
                fMonth = 7;
            }else if(tMonth == 'aug'){
                fMonth = 8;
            }else if(tMonth == 'sep'){
                fMonth = 9;
            }else if(tMonth == 'oct'){
                fMonth = 10;
            }else if(tMonth == 'nov'){
                fMonth = 11;
            }else if(tMonth == 'dec'){
                fMonth = 12;
            }
            
            if(isStart){
                tDate = String.ValueOf(Date.newInstance(tYear, fMonth, 1));
                tDate = tDate.left(10);
                tDate = tDate+'T00:00:00.000+0000';
            }else{
                Integer dInMonth = Date.daysInMonth(tYear, fMonth);
                tDate = String.ValueOf(Date.newInstance(tYear, fMonth, dInMonth));
                tDate = tDate.left(10);
                tDate = tDate+'T23:59:59.000+0000';
            }
            
             
            system.debug(tDate);
            
            
            return tDate;
        }catch(exception e){
            system.debug(e);
        }
        
        return null;
        
    } 
    
    public class ModelClass{
        public String question{get;set;}
        public String isApp{get;set;} 
        public Id vScoreCardId{get;set;}
        public String whichMonthYear{get;set;}
        public Id isSurveyId{get;set;}
    }
    
}