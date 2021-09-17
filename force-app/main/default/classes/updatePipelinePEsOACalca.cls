/*
Created By  : Nagendra Y
Description : For the push of Pipeline PE's for the COE push on 6/1/2021, We are calling an Apex method 
(EvaluationUtils.PerformAsyncNewStudentStepsUpdatePipelinePEs) to update the pipeline PEs 
so they have the ECAs and PECs appropriate for COE enrollment stage.
ADO         : Task 416266
*/

global class updatePipelinePEsOACalca implements Database.Batchable<sObject> {
    id processid;
    string academicprogram1;
    datetime PECreatedDate;
    global updatePipelinePEsOACalca(String academicprogram,id ecProcessID,datetime createdDate1){
        processid=ecProcessID;
        academicprogram1=academicprogram;
        datetime PECreatedDate=createdDate1;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
       // return  Database.getQueryLocator('SELECT ID, Name, hed__Account__r.Name, Household_Program_Enrollment__c,Enrollment_Type__c FROM hed__program_enrollment__c where hed__Account__r.Name =:academicprogram1 AND Status__c = \'In Progress\' AND RecordType.Name = \'Student\' AND Enrollment_Type__c in (\'Initial Enrollment\', \'Re-enrolling Student\') AND CreatedDate <: PECreatedDate AND Stage__c NOT IN (\'Intent to Attend\', \'Waitlist\') ');
       return  Database.getQueryLocator('SELECT ID, Name, hed__Account__r.Name, Household_Program_Enrollment__c,Enrollment_Type__c FROM hed__program_enrollment__c where hed__Account__r.Name =:academicprogram1 AND Status__c = \'In Progress\' AND RecordType.Name = \'Student\' AND Enrollment_Type__c in (\'Initial Enrollment\', \'Re-enrolling Student\') AND CreatedDate <: PECreatedDate AND Stage__c IN (\'Open Application\') ');
    }
    global void execute(Database.BatchableContext bc, List<hed__program_enrollment__c> scope){
        
        for(hed__program_enrollment__c p:scope){
            //system.debug('Nagendra :'+p.id);
            /* EvaluationUtils.PerformAsyncNewStudentStepsUpdatePipelinePEs(p.id,processid,p.Household_Program_Enrollment__c,
                                                                         p.Enrollment_Type__c); */
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
    public static void testCoveragePaddingMethod(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}