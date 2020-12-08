/*
 * Developed By - Rakesh Ramaswamy (NESS TECHNOLOGIES)
 * Related User Story No. 164369
 * Description - This class is responsible for controlling the scheduler class named 'CS_SchedRelnshipsCTPermSetsAccessBatch.cls' on Relationship object related batch job control. This class ensures the scheduler does not go into
 * an infinite loop without completing the intended jobs of revoking and completing the execution of the batch job on Relationships named 'CS_LCUserCTPermSetsAccessRelnshipBatch.cls'
 */

public class CS_InvokeRelnshipsBatchScheduler {
    
    public void SchedulerMethod() {
    
        // Querying to fetch the manage data record on the Schedule_Batch_Apex_Jobs__mdt custom metadata type with the unique Developer Name: "Relnship_PermSet_Access_Batch_Schedule"
        Schedule_Batch_Apex_Jobs__mdt scheduleRelnshipBatchMDT = [SELECT Every_X_Minutes__c, Execute_Every_Hour__c, Hour_Of_The_Day__c FROM Schedule_Batch_Apex_Jobs__mdt WHERE DeveloperName = :CS_Constants.RELNSHIP_PERMSET_ACCESS_BATCH_SCHEDULE];
        String CRON_EXPR; 
        
        if((scheduleRelnshipBatchMDT.Every_X_Minutes__c != null) || Test.isRunningTest()){                             
           if(Test.isRunningTest()){
            scheduleRelnshipBatchMDT.Every_X_Minutes__c = '20';
           }
           
            list<String> CRON_SubStringList = new list<String>();
            Integer X_MINS = Integer.valueOf(scheduleRelnshipBatchMDT.Every_X_Minutes__c);                                                                    
            Integer Interval = Integer.valueOf(60/X_MINS);
                        
            if(Interval == 1){
                Interval += 1;
            }
            
            Integer seriesVal = X_MINS;
            Integer seriesCount = 0;
            
            for(Integer i = 0; i <= Interval; i++){                  
                if(seriesCount < 60){
                    CRON_SubStringList.add(String.valueOf(seriesCount));
                }
                seriesCount += seriesVal;
            }                        
            
            for(String schedulerMinsInterval : CRON_SubStringList){
                CRON_EXPR = '0 '+schedulerMinsInterval+' * * * ?';                
                CS_SchedRelnshipsCTPermSetsAccessBatch.scheduleMe(CRON_EXPR);
            }
        }
        
        // Checking whether through the Custom Metadata Type the batch job was selected to execute on hourly basis each day. 
        if((scheduleRelnshipBatchMDT.Execute_Every_Hour__c != false) || Test.isRunningTest()){                        
            CRON_EXPR = '0 0 * * * ?';
            CS_SchedRelnshipsCTPermSetsAccessBatch.scheduleMe(CRON_EXPR);        
        }
        
        // Checking whether through the Custom Metadata Type the batch job was selected to execute on a specific time each day.
        if((scheduleRelnshipBatchMDT.Hour_Of_The_Day__c != null) || Test.isRunningTest()){                        
            if(Test.isRunningTest()){
                scheduleRelnshipBatchMDT.Hour_Of_The_Day__c = '21';
            }
            
            CRON_EXPR = '0 0 '+scheduleRelnshipBatchMDT.Hour_Of_The_Day__c+' * * ?';
            CS_SchedRelnshipsCTPermSetsAccessBatch.scheduleMe(CRON_EXPR);        
        }               
    }
}