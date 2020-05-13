/*
    Name: ScheduleBatchScorecardGenerator
    Author: 
     
    Description: This schedular class is used to execute BatchScorecardGenerator batch class. 
*/
global class ScheduleBatchScorecardGenerator implements Schedulable {
   global void execute(SchedulableContext SC) {
        /*
            String sch = '0 0 1 * * ? *';
            system.schedule('BatchScorecardGenerator', sch, new BatchScorecardGenerator());  
        */      
        database.executebatch(new BatchScorecardGenerator());
   }
}